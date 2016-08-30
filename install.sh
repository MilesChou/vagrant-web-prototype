#!/bin/bash
########################################
#                                      #
#  Install packages for Ubuntu 14.04   #
#                                      #
########################################

# Timeout 時間設定，單位是秒
TIMEOUT="3000"

# PHP 記憶體設定
MEMORY="128M"

IS_INSTALLED=".installed"

# Setup Timezone
TIMEZONE="Asia/Taipei"

# Setup packages and version
PACKAGES_LIST="
build-essential
curl
git
memcached
mongodb
mariadb-server
nginx
php-pear
php5-cli
php5-curl
php5-dev
php5-fpm
php5-mcrypt
php5-memcached
php5-mongo
php5-mysqlnd
php5-redis
php5-gd
php5-xdebug
redis-server
vim
"

PACKAGES=""
for package in $PACKAGES_LIST
do
    PACKAGES="$PACKAGES $package"
done

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
        fastcgi_read_timeout $TIMEOUT;
        fastcgi_index index.php;
        include fastcgi_params;

        # for solve 502 error
        fastcgi_buffers 16 16k;
        fastcgi_buffer_size 32k;
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

# update time
ntpdate time.stdtime.gov.tw

if [ ! -e $IS_INSTALLED ];then
    touch $IS_INSTALLED

    # update server
    apt-get update
    apt-get install python-software-properties

    # Add PHP 5.6 PPA
    add-apt-repository -y ppa:ondrej/php5-5.6
    apt-get update

    # set default root password
    export DEBIAN_FRONTEND=noninteractive
    debconf-set-selections <<< 'mariadb-server-5.5 mysql-server/root_password password password'
    debconf-set-selections <<< 'mariadb-server-5.5 mysql-server/root_password_again password password'

    # install packages
    apt-get install -y $PACKAGES $EXTENSIONS

    # set MySQL password and domain
    mysql -uroot -ppassword -e 'USE mysql; UPDATE `user` SET `Host`="%" WHERE `User`="root" AND `Host`="localhost"; DELETE FROM `user` WHERE `Host` != "%" AND `User`="root"; FLUSH PRIVILEGES;'
    mysql -uroot -ppassword -e 'CREATE DATABASE `default` DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_unicode_ci;'
    mysql -uroot -ppassword -e 'CREATE DATABASE `testing` DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_unicode_ci;'
    # mysql -uroot -ppassword -e "SET PASSWORD = PASSWORD('');"

    # modified mysql config
    sed -i 's/127\.0\.0\.1/0\.0\.0\.0/g' /etc/mysql/my.cnf

    # modified memcached config
    sed -i 's/127\.0\.0\.1/0\.0\.0\.0/g' /etc/memcached.conf

    # modified mongodb config
    sed -i 's/127\.0\.0\.1/0\.0\.0\.0/g' /etc/mongodb.conf

    # modified redis config
    sed -i 's/127\.0\.0\.1/0\.0\.0\.0/g' /etc/redis/redis.conf

    # modified php5-fpm conf
    sed -i 's/^listen =.*/listen = \/var\/run\/php5-fpm\.sock/g' /etc/php5/fpm/pool.d/www.conf
    sed -i 's/^;listen.owner =/listen.owner =/g' /etc/php5/fpm/pool.d/www.conf
    sed -i 's/^;listen.group =/listen.group =/g' /etc/php5/fpm/pool.d/www.conf
    sed -i 's/^;listen.mode =/listen.mode =/g' /etc/php5/fpm/pool.d/www.conf
    sed -i 's/^;clear_env =/clear_env =/g' /etc/php5/fpm/pool.d/www.conf

    # modified php.ini
    sed -i "s/^;date.timezone =.*/date.timezone = $TIMEZONE/g" /etc/php5/fpm/php.ini

    # install composer
    curl -sS https://getcomposer.org/installer | php
    mv composer.phar /usr/local/bin/composer

    # enable PHP module
    php5enmod mcrypt
fi

# modified php.ini
sed -i "s/^memory_limit =.*/memory_limit = $MEMORY/g" /etc/php5/fpm/php.ini
sed -i "s/^max_execution_time =.*/max_execution_time = $TIMEOUT/g" /etc/php5/fpm/php.ini
sed -i "s/^error_reporting =.*/error_reporting = E_ALL \| E_STRICT/g" /etc/php5/fpm/php.ini
sed -i "s/^display_errors =.*/display_errors = On/g" /etc/php5/fpm/php.ini
sed -i "s/^display_startup_errors =.*/display_startup_errors = On/g" /etc/php5/fpm/php.ini

# modified nginx default site
echo "$DEFAULT_SITE" > "/etc/nginx/sites-available/default"

# restart services
service php5-fpm restart
service nginx restart
service mysql restart
service memcached restart
service mongodb restart
service redis-server restart
