
# Use an webdevops PHP runtime as a parent image
FROM php:7.1-apache

ENV RUN_MODE="prod" \
    COMPOSER_UPDATE=0 \
    RUN_NPM_WATCH=0 \
    NPM_UPDATE=0 \
    SERVER_ROOT="/var/www/html" \
    CLEAR_SERVER_ROOT=0 \
    DB_SERVER=localhost \
    DB_PORT=3306 \
    DB_USER=root \
    DB_PASS=root \
    PATH=/usr/local/etc/nodejs/bin:$PATH

# Expose 80 port
EXPOSE 80

# Copy configuration to guest container
ADD ./docker_conf /tmp/conf
RUN chmod +x /tmp/conf/entrypoint.sh

# Install basic dependencies
RUN apt-get -yqq update; \
    apt-get -yqq install \
        git \
        unzip \
        libxml2-dev \
        mysql-client

# Install node and npm
ENV NODE_VER="v8.4.0-linux-x64"
ADD https://nodejs.org/dist/v8.4.0/node-"$NODE_VER".tar.xz /tmp
RUN mv -f /tmp/node-"$NODE_VER" /usr/local/etc/nodejs; \
    ln -s /usr/local/etc/nodejs/bin/node /usr/local/bin/node; \
    ln -s /usr/local/etc/nodejs/bin/npm /usr/local/bin/npm

# Install basic laravel dependencies
RUN docker-php-source extract; \
    docker-php-ext-install \
        tokenizer \
        mysqli \
        pdo_mysql \
        mbstring \
        libxml; \
    docker-php-source delete

# Install composer
RUN /usr/bin/curl -sS https://getcomposer.org/installer | /usr/local/bin/php; \
    /bin/mv composer.phar /usr/local/bin/composer

# Set the working directory to $SERVER_ROOT
WORKDIR "$SERVER_ROOT"

CMD ["/tmp/conf/entrypoint.sh"]
