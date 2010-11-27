#!/usr/bin/env ruby

require "fileutils"
require "optparse"
require "ostruct"

def log(*args)
  puts args
end

def trim_leading(string)
  r = string[/\A(\s*)/, 1]
  string.gsub(/^#{r}/, "")
end

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

@opts, opts = OpenStruct.new, OptionParser.new do |op|
  op.banner = "usage: #{File.basename(__FILE__)} <option>"
  op.separator ""

  op.on("-h",   "--help",    "show this message") { @opts.help   = true }
  op.on("-c", "--create",      "create new jail") { @opts.create = true }
  op.on("-u", "--update", "update existing jail") { @opts.update = true }
end
opts.parse! ARGV

if @opts.help || @opts.create == @opts.update
  log opts
  exit 0
end

log "Running tests..."
Dir["test/*_test.rb"].each do |file|
  output = %x(ruby -Itest #{file})
  abort(output) unless $? == 0
end

if @opts.create
  log "Creating a new jail..."
  abort "#{Tor.chroot} exists" if File.exist?(Tor.chroot)
  FileUtils.mkdir_p Tor.chroot.join("dev")
end

if @opts.update
  log "Updating an existing jail..."
  abort "#{Tor.chroot} does not exist" unless File.exist?(Tor.chroot)
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

if @opts.update
  @copy_files.reject! { |file| file =~ /\A\/(dev|etc|var)/ }
end

@copy_files.each do |file|
  FileUtils.mkdir_p  Tor.chroot.join(File.dirname(file))
  %x(cp -fp #{file} #{Tor.chroot.join(file)})
end

if @opts.create
  %x(grep ^tor: /etc/passwd > #{ Tor.chroot.join 'etc/passwd' })
  %x(grep ^tor: /etc/group  > #{ Tor.chroot.join 'etc/group'  })

  %w(lib log run).each do |dir|
    FileUtils.mkdir_p     Tor.chroot.join("var", dir, "tor")
    FileUtils.chmod 0700, Tor.chroot.join("var", dir, "tor")
  end

  open(Tor.chroot.join("etc/tor/torrc"), "w") do |torrc|
    torrc.write trim_leading <<-__EOF__
      ClientOnly    1
      DataDirectory /var/lib/tor
      Log           notice stderr
      PidFile       /var/run/tor/tor.pid
      RunAsDaemon   0
      SafeSocks     1
      User          tor
    __EOF__
  end

  log trim_leading <<-__EOF__
    Almost done. Perform the following commands as root to complete
    the installation:

      chown tor:tor #{ Tor.chroot.join "var", "{lib,log,run}", "tor" }
      mknod -m 644  #{ Tor.chroot.join "dev/random" }  c 1 8
      mknod -m 644  #{ Tor.chroot.join "dev/urandom" } c 1 9
      mknod -m 666  #{ Tor.chroot.join "dev/null" }    c 1 3
  __EOF__
end

if @opts.update
  log "Done."
end

exit 0
