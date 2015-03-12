#!/bin/bash
####################################
#                                  #
#  Install packages for prototype  #
#                                  #
####################################

# Setup Timezone
TIMEZONE="Asia/Taipei"

# Setup packages and version

DEFAULT_PACKAGES_LIST="
git
vim
curl
php5-fpm
php5-cli
php5-xdebug
"

DEFAULT_PACKAGES=""
for package in $DEFAULT_PACKAGES_LIST
do
    DEFAULT_PACKAGES="$DEFAULT_PACKAGES $package"
done

# Configurations
DEFAULT_SITE="
server {
    listen 80;

    root /vagrant/public;
    index index.html index.htm index.php;

    server_name localhost;

    location / {
        try_files \$uri \$uri/ =404 /index.php\$is_args\$args;
        expires off;
    }

    location ~ \.php\$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)\$;
        fastcgi_pass unix:/var/run/php5-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;

        # for Zend Framework
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        fastcgi_param APPLICATION_ENV development;
    }

    location ~ /\.ht {
        deny all;
    }
}
"

# is root?
if [ "`whoami`" != "root" ]; then
    echo "You may use root permission!"
    exit 1
fi

# set time zone
ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime

# update server
apt-get update

# install packages
apt-get install -y $DEFAULT_PACKAGES

# modified php.ini
sed -i 's/^error_reporting =.*/error_reporting = E_ALL \| E_STRICT/g' /etc/php5/fpm/php.ini
sed -i 's/^display_errors =.*/display_errors = On/g' /etc/php5/fpm/php.ini
sed -i 's/^display_startup_errors =.*/display_startup_errors = On/g' /etc/php5/fpm/php.ini

# modified php5-fpm conf
# unix:/var/run/php5-fpm.sock
sed -i 's/^listen =.*/listen = \/var\/run\/php5-fpm\.sock/g' /etc/php5/fpm/pool.d/www.conf
sed -i 's/^;listen.owner =/listen.owner =/g' /etc/php5/fpm/pool.d/www.conf
sed -i 's/^;listen.group =/listen.group =/g' /etc/php5/fpm/pool.d/www.conf
sed -i 's/^;listen.mode =/listen.mode =/g' /etc/php5/fpm/pool.d/www.conf

# modified nginx default site
echo "$DEFAULT_SITE" > "/etc/nginx/sites-available/default"

# restart service
service php5-fpm restart
service nginx restart

# servers
# set default root password
echo "mysql-server mysql-server/root_password password password" | debconf-set-selections
echo "mysql-server mysql-server/root_password_again password password" | debconf-set-selections

# install mysql server
apt-get install -y mysql-server
sed -i 's/127\.0\.0\.1/0\.0\.0\.0/g' /etc/mysql/my.cnf
service mysql restart
mysql -uroot -ppassword -e 'USE mysql; UPDATE `user` SET `Host`="%" WHERE `User`="root" AND `Host`="localhost"; DELETE FROM `user` WHERE `Host` != "%" AND `User`="root"; FLUSH PRIVILEGES;'
mysql -uroot -ppassword -e 'CREATE DATABASE `default` DEFAULT CHARACTER SET `utf8` COLLATE `utf8_general_ci`;'
mysql -uroot -ppassword -e "SET PASSWORD = PASSWORD('');"

# install composer
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer

# initial slim framework
cd /vagrant && composer install
