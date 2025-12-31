We are freshly installing Debian Trixie version of Raspberry PI OS https://www.raspberrypi.com/software/ onto a Raspberry Pi 5.

The baseline for the device is to have:

* Docker server on boot
* sshd with no password authentication `ssh pi@192.168.1.34` should work already
* Tailscale, it was previously a exit node configured as "five" on kaihendry.github 

My Ubiquiti network at 81.187.243.70 has been forwarding to the Pi 5 on a "statically" assigned IP address:

* 192.168.1.34:443
* 192.168.1.34:80
