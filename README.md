tor-chroot-al
=============

Installs [Tor][1] in a chroot environment on [Arch Linux][2]. It assumes
that Tor is installed as an Arch package, and by that its dependencies.
I made it for use with the [Tor server][3] I run. Originally based on
[this][4] document.

Usage
-----

* Run `pacman -S ruby tor` if needed.
* Run `ruby build.rb -c` to create a new environment under `./chroot`. This
  will also output some instructions which must be performed as root.
* To update an existing `./chroot`, run `ruby build.rb -u`. This will leave
  `./chroot/{dev,etc,var}` alone and overwrite everything else.
* The default `torrc` installed will only run Tor as a client, in the
  foreground, and log to stderr.
* To start Tor jailed: `chroot ./chroot /usr/bin/tor -f /etc/tor/torrc`.

[1]: http://www.torproject.org/
[2]: http://www.archlinux.org/
[3]: http://tor-proxy.knegg.org/
[4]: https://wiki.torproject.org/noreply/TheOnionRouter/TorInChroot
