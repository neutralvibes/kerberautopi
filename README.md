# kerberautopi

Script installation of kerberos.io on pi zero.

## Installation

### System

Write lite version of pi image to sd card

Add `wpa_supplicant.conf` on boot partition

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

Create empty `ssh` file on boot partition and boot pi from card.

Login to pi, update system files and change default password.

```bash
sudo apt update && sudo apt upgrade -y
passwd
```

In raspi-config

* Set hostname 
* Enable pi camera
* Enable predictable network interface names

```bash
sudo raspi-config
```

Reboot

```bash
sudo reboot
```

```bash
wget https://raw.githubusercontent.com/neutralvibes/kerberautopi/main/kerber_install.sh

chmod +x kerber_install.sh
```
