#!/usr/bin/env bash

# Add PHP 5.4 PPA
# --------------------
apt-get update
apt-get update
apt-get dist-upgrade

# Install Apache & PHP
# --------------------
apt-get install -y apache2
apt-get install -y php5
apt-get install -y libapache2-mod-php5
apt-get install -y  php5-curl php5-gd php5-intl php-pear php5-imap php5-mcrypt php5-ming php5-ps php5-pspell php5-recode php5-sqlite php5-tidy php5-xmlrpc php5-xsl php-apc

# Delete default apache web dir and symlink mounted vagrant dir from host machine
# --------------------
mkdir -p /var/www

# Replace contents of default Apache vhost
# --------------------
VHOST=$(cat <<EOF
<VirtualHost *:80>
  DocumentRoot "/var/www"
  ServerName .dev
  <Directory "/var/www">
    AllowOverride All
  </Directory>
</VirtualHost>
EOF
)

echo "$VHOST" > /etc/apache2/sites-enabled/000-default

a2enmod rewrite
service apache2 restart

export DEBIAN_FRONTEND=noninteractive