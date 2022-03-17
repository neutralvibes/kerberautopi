# Kerberautopi

Automated install of camera surveillance system [kerberos.io](https://kerberos.io) v2.8.0 for Raspberry PI Zero.

## Why?

As time goes by SD cards wear, OS versions change etc. Needing to run a few other services, the advanced installation of kerberos.io was a better fit for me. However, there are a few steps to getting things going which can be a pain. With that in mind I created this script to simplify the installation of V2.8.0 on a Raspberry PI Zero. While it may work on others it hasn't been tested on anything else.

Any improvements / additions are welcome.

## What it does

Installs the following:-

* ffmpeg and fixes
* php7.4 and dependencies
* Kerberos Machinery v2.8.0
* Kerberos Web v2.8.0
* Nginx - also creates config file
* Creates autoremoval script in `bin`folder (still needs scheduling)

_Please be aware the Nginx setup will remove the `default` file and create a `kerberosio.conf` one._

## Installation

If you have already flashed a card and setup the system you can skip to [Installing Kerberosio](#installing-kerberosio). Otherwise continue reading.


### Preparing basic system

__Important__

As the latest OS version at the time of writing is now Bullseye, in-order to use this script the **legacy buster** lite image must be used. This must be selected from the PI Imager or downloaded and written manually.

*Note if using the Raspberry PI Imager (recommended) you can skip these steps but still need to enable the camera if using it.*

Download and write a lite version of pi OS image to SD card.

Add `wpa_supplicant.conf` file on the boot partition updated with the appropriate information.

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

Create an empty `ssh` file on the boot partition and boot pi from card.

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
wget https://raw.githubusercontent.com/neutralvibes/kerberautopi/main/kerber_install.sh && chmod +x kerber_install.sh
```

Run it

```bash
./kerber_install.sh
```

Select [a] for all then press [enter]

It will take a while but you should (hopefully) have a working installation of kerberosio once finished.


## Change Log

2022/03/15 Reverted to Buster image image & PHP 7.1 because of problems with configuration pages under 7.4
2022/02/28 Updated for Bullseye image & PHP 7.4
