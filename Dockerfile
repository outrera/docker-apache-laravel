
# Use an webdevops PHP runtime as a parent image
FROM php:7.1-apache

ENV RUN_MODE="prod" \
    SERVER_ROOT="/var/www/html" \
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
RUN apt-get -yqq update && \
    apt-get -yqq install apt-transport-https

# Add yarn repo
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

# Install basic dependencies
RUN apt-get -yqq update && \
    apt-get -yqq install \
        git \
        unzip \
        libxml2-dev \
        yarn

# Install node and npm
ENV NODE_VER="v8.4.0-linux-x64"
RUN curl -sS https://nodejs.org/dist/v8.4.0/node-"$NODE_VER".tar.xz > /tmp/node-"$NODE_VER".tar.xz && \
    tar -xJf /tmp/node-"$NODE_VER".tar.xz -C /tmp/ && \
    cp -rf /tmp/node-"$NODE_VER"/ /usr/local/etc/nodejs/ && \
    ln -s /usr/local/etc/nodejs/bin/node /usr/local/bin/node && \
    ln -s /usr/local/etc/nodejs/bin/npm /usr/local/bin/npm

# Install basic laravel dependencies
RUN docker-php-source extract && \
    docker-php-ext-install \
        tokenizer \
        mysqli \
        pdo_mysql \
        mbstring \
        libxml; \
    docker-php-source delete

# Install composer
RUN /usr/bin/curl -sS https://getcomposer.org/installer | /usr/local/bin/php && \
    /bin/mv composer.phar /usr/local/bin/composer

# Set the working directory to $SERVER_ROOT
WORKDIR "$SERVER_ROOT"

CMD ["/tmp/conf/entrypoint.sh"]
