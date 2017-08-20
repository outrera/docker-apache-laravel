#!/bin/bash


# Warn
if [ $RUN_MODE == "prod" -o $RUN_MODE == "production" ]; then
    echo "* Running container in production mode"
else
    echo "* Running container in dev mode"
fi

/bin/chown www-data:www-data -R "$SERVER_ROOT/storage" "$SERVER_ROOT/bootstrap/cache"

# Generate new app key
/usr/local/bin/php artisan key:generate > /dev/null &


### Setup apache for laravel
echo "* Setting up apache"

if [ ! -f /etc/apache2/sites-available/000-laravel.conf ]; then
    mv /tmp/conf/000-laravel.conf /etc/apache2/sites-available/
    mv /tmp/conf/001-laravel-ssl.conf /etc/apache2/sites-available/
fi

/usr/sbin/a2dissite '*'
/usr/sbin/a2ensite 000-laravel 001-laravel-ssl

# Enable apache rewrite
a2enmod rewrite

echo "* Almost ready, starting apache"

exec apache2ctl -D FOREGROUND
