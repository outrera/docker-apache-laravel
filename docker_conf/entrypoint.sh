#!/bin/bash


# Warn
if [ $RUN_MODE == "prod" -o $RUN_MODE == "production" ]; then
    echo "* Running container in production mode"
else
    echo "* Running container in dev mode"
fi

/bin/chown www-data:www-data -R "$SERVER_ROOT/storage" "$SERVER_ROOT/bootstrap/cache"

# Prepare laravel and static files
if [ $RUN_MODE == "prod" -o $RUN_MODE == "production" ]; then
    /usr/local/bin/composer install --no-dev -o --apcu-autoloader
    /usr/bin/yarn install
    /usr/bin/yarn run prod
fi

# Create .env file
if [ ! -f .env ]; then
    cp .env.example .env
fi

# Generate new app key
/usr/local/bin/php artisan key:generate > /dev/null &


### Setup apache for laravel
echo "* Setting up apache"

if [ ! -f /etc/apache2/sites-available/000-laravel.conf ]; then
    cp /tmp/conf/000-laravel.conf /etc/apache2/sites-available/
    cp /tmp/conf/001-laravel-ssl.conf /etc/apache2/sites-available/
fi

/usr/sbin/a2dissite '*'
/usr/sbin/a2ensite 000-laravel 001-laravel-ssl

# Enable apache mods: rewrite, headers
a2enmod rewrite

if [ $RUN_MODE == "prod" -o $RUN_MODE == "production" ]; then
    a2enmod headers cache_disk
fi

echo "* Almost ready, starting apache"

exec apache2ctl -D FOREGROUND
