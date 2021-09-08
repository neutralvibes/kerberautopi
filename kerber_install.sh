#!/bin/bash

PIV=rpi1
VER=2.8.0
X265_VER=160
X264_VER=148

msg () {
  echo -e $@
}

checkLib () {
  msg Checking lib $1
  if [[ ! -f /usr/lib/arm-linux-gnueabihf/$1 ]]; then
    msg "Downloading $1"
    wget https://github.com/kerberos-io/machinery/releases/download/v$VER/$PIV-$1
      
    if [ $? != 0 ]; then
      msg "\n\tLib $1 download failed"
      exit 1
    fi
      sudo mv $PIV-$1 /usr/lib/arm-linux-gnueabihf/$1
  else
    msg $1 Already present
  fi
}

machine() {
  sudo apt-get update && sudo apt-get install -y ffmpeg

  msg "Downloading version $VER"

  wget https://github.com/kerberos-io/machinery/releases/download/v$VER/$PIV-machinery-kerberosio-armhf-$VER.deb

  if [ $? != 0 ]; then
    msg "\n\tMachinery download failed"
    exit 1
  fi

  msg "Installing version $VER"
  sudo dpkg -i $PIV-machinery-kerberosio-armhf-$VER.deb

  checkLib libx265.so.$X265_VER
  checkLib libx264.so.$X264_VER

  sudo systemctl enable kerberosio
  sudo service kerberosio start
}

nginxSetup () {
  local fd=/etc/nginx/sites-enabled
  local fn=$fd/kerberosio.conf

  if [[ ! -f $fn ]]; then
    msg "Setting up Nginx"
    sudo rm -f /etc/nginx/sites-enabled/default
    sudo echo "
    server
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
        fastcgi_pass unix:/var/run/php/php7.1-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
      }
    }
    " > $fn
  else
    msg "Nginx already setup"
  fi
  
  msg "Restarting Nginx"
  sudo service nginx restart
}

web () {
  msg Installing php

  sudo apt-get install -y \
    nginx \
    php7.1 \
    php7.1-curl \
    php7.1-gd \
    php7.1-fpm \
    php7.1-cli \
    php7.1-opcache \
    php7.1-mbstring \
    php7.1-xml \
    php7.1-zip \
    php7.1-mcrypt \
    php7.1-readline

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
    partition=/dev/root
    imagedir=/etc/opt/kerberosio/capture/
    if [[ \$(df -h | grep \$partition | head -1 | awk -F' ' '{ print \$5/1 }' | tr ['%'] [\"0\"]) -gt 90 ]];
    then
        echo 'Cleaning disk'
        find \$imagedir -type f | sort | head -n 100 | xargs -r rm -rf;
    else
        echo 'No cleaning required'
    fi;
    " > $fn
    chmod +x $fn
  else
    msg $fn already exists
  fi
}

machine
web
autoremoval
msg "\nCompleted."

