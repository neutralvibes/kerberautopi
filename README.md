# Kerberautopi

Automated install of camera surveillance system of kerberos.io v2.8.0

## Why?

As time goes by SD cards wear, OS versions change etc. Needing to run a few other services the advanced installation of kerberos.io was a better fit for me. However, there are a few steps to getting things going which can be a pain. With this in mind I created this script to simplify the installation of V2.8.0 on a Raspberry PI Zero. While it may work on others it hasn't been tested on anything else. Any improvements / additions are welcome.

## What it does

Installs the following:-

* ffmpeg and fixes
* php7.1 and dependencies
* Kerberos Machinery v2.8.0
* Kerberos Web v2.8.0
* Nginx - also creates config file
* Creates autoremoval script in `bin`folder (still needs scheduling)

_Please be aware the Nginx setup will remove the `default` file and create a `kerberosio.conf` one._

## Installation

If you have already flashed a card and setup the system you can skip to [Installing Kerberosio](#installing-kerberosio). Otherwise continue reading.


### Preparing basic system

Download and write lite version of pi image to sd card.

Add `wpa_supplicant.conf` on boot partition updated with the appropriate information.

```nano
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
country=<Insert 2 letter ISO 3166-1 country code here>

network={
        scan_ssid=1
        ssid="<Name of your wireless LAN>"
        psk="<Password for your wireless LAN>"
        proto=RSN
        key_mgmt=WPA-PSK
        pairwise=CCMP
        auth_alg=OPEN
}
```

Create an empty `ssh` file on boot partition and boot pi from card.

Login to pi, update system files and change default password.

```bash
sudo apt update && sudo apt upgrade -y
passwd
```

In raspi-config

```bash
sudo raspi-config
```

* Set hostname
* Enable pi camera (if using)
* Enable predictable network interface names

Reboot

### Installing Kerberosio

Download the script

```bash
wget https://raw.githubusercontent.com/neutralvibes/kerberautopi/main/kerber_install.sh
```

Make runnable

```bash
chmod +x kerber_install.sh
```

Run it

```bash
kerber_install.sh
```

You should now (hopefully) have a working installation.
