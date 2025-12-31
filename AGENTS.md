We are freshly installing Debian Trixie version of Raspberry PI OS https://www.raspberrypi.com/software/ onto a Raspberry Pi 5.

The baseline for the device is to have:

* Docker server on boot
* sshd
* Tailscale via https://tailscale.com/kb/1211/pulumi-provider

My Ubiquiti network at 81.187.243.70 has been fowarding to the Pi 5 on a "statically" assigned IP address:

* 192.168.1.34:443
* 192.168.1.34:80
