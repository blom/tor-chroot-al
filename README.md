tor-chroot-al
=============

* [Homepage](https://github.com/blom/tor-chroot-al)

Installs [Tor][1] in a chroot environment on [Arch Linux][2]. It assumes that
Tor is installed as an [Arch package][3], and by that its dependencies. Made
for use with a Tor server I used to run. Originally based on [this][4]
document.

Installation
------------

    pacman -S git ruby tor
    git clone https://github.com/blom/tor-chroot-al.git

Usage
-----

### Creating a new environment

    ruby build.rb -c

* Creates a new environment under `./chroot`.
* Outputs some commands to run as root.

### Updating an existing environment

    ruby build.rb -u

* Leaves `./chroot/{dev,etc,var}` alone and overwrites everything else.

### Running

    chroot ./chroot /usr/bin/tor -f /etc/tor/torrc

* The default `torrc` installed will only run Tor as a client, in the
  foreground, and log to stderr.

[1]: http://www.torproject.org/
[2]: http://www.archlinux.org/
[3]: http://repos.archlinux.org/wsvn/packages/tor/trunk/
[4]: https://trac.torproject.org/projects/tor/wiki/TheOnionRouter/TorInChroot
