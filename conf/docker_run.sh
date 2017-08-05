#!/bin/bash

# Install composer
if [ ! -f /usr/local/bin/composer ]; then
    echo "* Installing Composer"
    /usr/bin/curl -sS https://getcomposer.org/installer | /usr/local/bin/php
    /bin/mv composer.phar /usr/local/bin/composer
fi


# Install laravel
if [ ! -f ./composer.json ]; then
    echo "* Installing Laravel"

    /usr/local/bin/composer create-project laravel/laravel "$SERVER_ROOT" --prefer-dist
    /bin/chown www-data:www-data -R "$SERVER_ROOT/storage" "$SERVER_ROOT/bootstrap/cache"

    /usr/local/bin/npm install
else
    echo "* Updating composer packages"

    cp .env.example .env
    /usr/local/bin/composer update

    /usr/local/bin/npm update
fi

# Generate new app key
php artisan key:generate


RET=1
while [ $RET -ne 0 ]; do
    mysql -h$DB_SERVER -P$DB_PORT -u$DB_USER -p$DB_PASS -e "status" > /dev/null 2>&1
    RET=$?
    if [ $RET -ne 0 ]; then
        echo "* Waiting for confirmation of MySQL service startup";
        sleep 5
    fi
done

# Setup apache for laravel
echo "* Setting up apache"

if [ ! -f /etc/apache2/sites-available/000-laravel.conf ]; then
    mv /tmp/conf/000-laravel.conf /etc/apache2/sites-available/
    mv /tmp/conf/001-laravel-ssl.conf /etc/apache2/sites-available/
fi

/usr/sbin/a2dissite '*'
/usr/sbin/a2ensite 000-laravel 001-laravel-ssl

echo "* Apache is ready, starting"

apache2ctl -D FOREGROUND
