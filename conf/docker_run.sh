#!/bin/bash

### Install laravel
if [ ! -f /var/www/html/composer.lock ]; then
    echo "* Installing Laravel"

    if [ $CLEAR_SERVER_ROOT == 1 ]; then
        rm -rf "$SERVER_ROOT/*"
    else
        echo "* Laravel won't install if directory isn't empty"
    fi

    if [ $RUN_MODE == "prod" -o $RUN_MODE == "production" ]; then
        /usr/local/bin/composer create-project laravel/laravel "$SERVER_ROOT" --no-dev --prefer-dist
    else
        /usr/local/bin/composer create-project laravel/laravel "$SERVER_ROOT"
    fi
else
    echo "* Updating composer packages"

    cp .env.example .env

    if [ $RUN_MODE == "prod" -o $RUN_MODE == "production" ]; then
        /usr/local/bin/composer update --no-dev --prefer-dist
    else
        /usr/local/bin/composer update
    fi
fi

/bin/chown www-data:www-data -R "$SERVER_ROOT/storage" "$SERVER_ROOT/bootstrap/cache"

# Generate new app key
php artisan key:generate

## Install/Update npm packages
if [ ! -f /var/www/html/package.json ]; then
    if [ ! -f /var/www/html/package-lock.json ]; then
        echo "* Downloading npm packages"
        /usr/local/bin/npm install
    else
        echo "* Updating npm packages"
        /usr/local/bin/npm update
    fi

    # Setup npm based on run mode
    echo "* Running npm setup"
    if [ $RUN_MODE == "prod" -o $RUN_MODE == "production" ]; then
        npm run prod
    else
        npm run watch &
    fi
fi


### Setup apache for laravel
echo "* Setting up apache"

if [ ! -f /etc/apache2/sites-available/000-laravel.conf ]; then
    mv /tmp/conf/000-laravel.conf /etc/apache2/sites-available/
    mv /tmp/conf/001-laravel-ssl.conf /etc/apache2/sites-available/
fi

/usr/sbin/a2dissite '*'
/usr/sbin/a2ensite 000-laravel 001-laravel-ssl

echo "* Almost ready, starting apache"

exec apache2ctl -D FOREGROUND
