#!/bin/bash

PIV=rpi1

# PHP Version
PHP_VER=7.1

# Kerberos Machine Version
MACH_VER=2.8.0

# FFMPG version
X265_VER=160
X264_VER=148

# Extra lib path  
EXTRA_LIB_URL=https://github.com/neutralvibes/kerberautopi/raw/main/lib

msg () {
  echo -e $@
}

getFFMPEGLib () {
  msg Checking lib $1

  if [[ ! -f /usr/lib/arm-linux-gnueabihf/$1 ]]; then
    msg "Downloading $1"
    wget https://github.com/kerberos-io/machinery/releases/download/v$MACH_VER/$PIV-$1
      
    if [ $? != 0 ]; then
      msg "\n\tLib $1 download failed"
      exit 1
    fi
      sudo mv $PIV-$1 /usr/lib/arm-linux-gnueabihf/$1
  else
    msg $1 Already present
  fi
}

getExtraLib () {

  msg Checking lib $1

  if [[ ! -f /usr/lib/arm-linux-gnueabihf/$1 ]]; then
    msg "Downloading $1"
    wget $EXTRA_LIB_URL/$1
      
    if [ $? != 0 ]; then
      msg "\n\tLib $1 download failed"
      exit 1
    fi
      sudo mv $1 /usr/lib/arm-linux-gnueabihf/$1
  else
    msg $1 Already present
  fi
}

machine() {
  sudo apt-get update && sudo apt-get install -y ffmpeg

  msg "Downloading machine version $MACH_VER"

  wget https://github.com/kerberos-io/machinery/releases/download/v$MACH_VER/$PIV-machinery-kerberosio-armhf-$MACH_VER.deb

  if [ $? != 0 ]; then
    msg "\n\tMachinery download failed"
    exit 1
  fi

  msg "Installing machine version $MACH_VER"
  sudo dpkg -i $PIV-machinery-kerberosio-armhf-$MACH_VER.deb

  getFFMPEGLib libx265.so.$X265_VER
  getFFMPEGLib libx264.so.$X264_VER

  getExtraLib libEGL.so
  getExtraLib libGLESv2.so
  getExtraLib libopenmaxil.so

  sudo systemctl enable kerberosio
  sudo service kerberosio start
}

nginxSetup () {
  local fd=/etc/nginx/sites-enabled
  local fn=$fd/kerberosio.conf

  if [[ ! -f $fn ]]; then
    msg "Setting up Nginx"

    sudo rm -f /etc/nginx/sites-enabled/default
    
    sudo echo "server
    {
      listen 80 default_server;
      listen [::]:80 default_server;
      root /var/www/web/public;
      server_name kerberos.rpi;
      index index.php index.html index.htm;
      location /
      {
        autoindex on;
        try_files \$uri \$uri/ /index.php?\$query_string;
      }
      location ~ \.php$
      {
        fastcgi_pass unix:/var/run/php/php$PHP_VER-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
      }
    }
    " > ~/kerberosio.conf
    sudo mv ~/kerberosio.conf $fn
  else
    msg "Nginx already setup"
  fi

  msg "Restarting Nginx"
  sudo service nginx restart
}

nginxApp () {
  msg Installing nginx

  sudo apt-get install nginx -y
  nginxSetup
}

phpApp () {
  msg Installing php

  sudo apt-get install -y \
    nginx \
    php$PHP_VER \
    php$PHP_VER-dev \
    libmcrypt-dev \
    php-pear \
    php$PHP_VER-curl \
    php$PHP_VER-gd \
    php$PHP_VER-fpm \
    php$PHP_VER-cli \
    php$PHP_VER-opcache \
    php$PHP_VER-mbstring \
    php$PHP_VER-xml \
    php$PHP_VER-zip \
    php$PHP_VER-readline

    pear config-set php_ini /etc/php/$PHP_VER/fpm/php.ini
    sudo pecl channel-update pecl.php.net
    printf "\n" | sudo pecl install channel://pecl.php.net/mcrypt-1.0.4
}

web () {
  msg Installing Web
  sudo mkdir -p /var/www/web && sudo chown www-data:www-data /var/www/web
  cd /var/www/web
  sudo -u www-data wget https://github.com/kerberos-io/web/releases/download/v2.8.0/web.tar.gz
  sudo -u www-data tar xvf web.tar.gz .
  sudo chown www-data -R storage bootstrap/cache config/kerberos.php
  sudo chmod -R 775 storage bootstrap/cache
  sudo chmod 0600 config/kerberos.php
  
  nginxSetup
}

autoremoval () {
  msg "Checking auto removal file"
  local fd=/home/pi/bin
  local fn=$fd/autoremoval.sh
  mkdir -pv $fd

  if [[ ! -f $fn ]]; then
    echo "
# Partition to check
partition=/dev/root

# Image folder
imagedir=/etc/opt/kerberosio/capture/

# Threshold for file removal
maxPercent=80

# Maximum no of files to remove when threshold reached
removeCount=250

msg () {
  echo '$(date +'%Y-%m-%d %X') $1'
}

msg 'Checking if space usage over $maxPercent%'

if [ $(df -h | grep $partition | head -1 | awk -F' ' '{ print $5/1 }' | tr ['%'] ["0"]) -gt $maxPercent ]
then
  msg 'Cleaning disk of $removeCount files'
  find $imagedir -type f | sort | head -n $removeCount | xargs -r rm -rf;
else
  msg 'No cleaning required'
fi;

    " > $fn
    chmod +x $fn
  else
    msg $fn already exists
  fi

  msg "autoremoval script may still need scheduling."
}

msg "Choose Kerberospi install item"
msg "\t[m]achine, \n\t[w]eb, \n\t[n]ginx, \n\t[p]hp, \n\t[a]ll \n\t[q]uit"

read -r -p "?: " input

case $input in 
  m)
    machine
    exit $?
    ;;

  w)
    web
    exit $?
    ;;

  n)
    nginxApp
    exit $?
    ;;

  p)
    phpApp
    exit $?
    ;;

  a)
    machine
    nginxApp
    phpApp
    web
    autoremoval
    exit $?
    ;;

esac
msg "\nCompleted."

