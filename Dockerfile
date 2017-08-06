
# Use an webdevops PHP runtime as a parent image
FROM php:7.1-apache

ENV RUN_MODE="prod"
ENV SERVER_ROOT="/var/www/html"
ENV DB_SERVER=localhost
ENV DB_PORT=3306
ENV DB_USER=root
ENV DB_PASS=root

EXPOSE 80

ADD conf /tmp/conf

# Install basic dependencies
RUN apt-get -yqq update; \
    apt-get -yqq install \
        git \
        unzip \
        libxml2-dev \
        mysql-client

# Install node and npm
ADD https://nodejs.org/dist/v8.2.1/node-v8.2.1-linux-x64.tar.xz /tmp
RUN mv /tmp/node-v8.2.1-linux-x64 /usr/local/etc/nodejs; \
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

# Set the working directory to /var/www/html
WORKDIR /var/www/html

CMD ["/tmp/conf/docker_run.sh"]
