#!/usr/bin/env ruby

require "fileutils"

module Tor
  module_function
  DIR_BASE   = File.expand_path("..", __FILE__)
  DIR_CHROOT = "chroot"

  class AJoin < String
    def initialize(path)
      super(path)
    end

    def join(*paths)
      File.join(self, *paths)
    end
  end

  def chroot
    @@chroot ||= AJoin.new(File.join(DIR_BASE, DIR_CHROOT))
  end
end

if File.exist? Tor.chroot
  abort "directory #{Tor.chroot} already there -- will exit"
else
  FileUtils.mkdir_p Tor.chroot.join("dev")
end

Dir.glob("test/*_test.rb").each do |file|
  output = %x(ruby #{file})
  abort(output) unless $? == 0
end

@copy_files = Dir.glob(%w(
  /etc/host.conf
  /etc/hosts
  /etc/localtime
  /etc/nsswitch.conf
  /etc/resolv.conf
  /lib/ld-linux.so.2
  /lib/libnsl*
  /lib/libnss*
  /lib/libresolv*
  /usr/lib/libgcc_s.so.*
  /usr/lib/libnss*.so
))

[%x(pacman -Qlq tor), %x(ldd /usr/bin/tor)].each do |files|
  @copy_files += files.split.reject do |file|
    File.directory?(file) || !File.exist?(file)
  end
end

@copy_files = @copy_files.uniq.sort

@copy_files.each do |file|
  FileUtils.mkdir_p  Tor.chroot.join(File.dirname(file))
  FileUtils.cp file, Tor.chroot.join(file), :preserve => true
end

%x(grep ^tor: /etc/passwd > #{ Tor.chroot.join 'etc/passwd' })
%x(grep ^tor: /etc/group  > #{ Tor.chroot.join 'etc/group'  })

%w(lib log run).each do |dir|
  FileUtils.mkdir_p     Tor.chroot.join("var", dir, "tor")
  FileUtils.chmod 0700, Tor.chroot.join("var", dir, "tor")
end

open(Tor.chroot.join("etc/tor/torrc"), "w") do |torrc|
torrc << <<-__EOF__
ClientOnly    1
DataDirectory /var/lib/tor
Log           notice stderr
PidFile       /var/run/tor/tor.pid
RunAsDaemon   0
SafeSocks     1
User          tor
__EOF__
end

puts <<-__EOF__
Perform the following commands as root to complete the installation:

  chown -R 0:0  #{ Tor.chroot }
  chown tor:tor #{ Tor.chroot.join "var", "{lib,log,run}", "tor" }
  mknod -m 644  #{ Tor.chroot.join "dev/random" }  c 1 8
  mknod -m 644  #{ Tor.chroot.join "dev/urandom" } c 1 9
  mknod -m 666  #{ Tor.chroot.join "dev/null" }    c 1 3
__EOF__
