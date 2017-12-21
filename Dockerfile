
# Use an official PHP runtime with apache as a parent image
FROM php:7.2-apache


ENV RUN_MODE="prod" \
    SERVER_ROOT="/var/www/html" \
    DB_SERVER=localhost \
    DB_PORT=3306 \
    DB_USER=root \
    DB_PASS=root


# Expose 80 port
EXPOSE 80


# Copy configuration into container
ADD ./docker_conf /tmp/conf
RUN chmod +x /tmp/conf/entrypoint.sh


# Install basic dependencies
RUN apt-get -yqq update && \
    apt-get -yqq install \
      apt-transport-https \
      gnupg


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
ENV NODE_VER="v8.9.3" \
    NODE_ARC="linux-x64"

RUN curl -sS https://nodejs.org/dist/"$NODE_VER"/node-"$NODE_VER-$NODE_ARC".tar.xz > /tmp/node-"$NODE_VER-$NODE_ARC".tar.xz && \
    tar -xJf /tmp/node-"$NODE_VER-$NODE_ARC".tar.xz -C /tmp/ && \
    cp -rf /tmp/node-"$NODE_VER-$NODE_ARC"/ /usr/local/etc/nodejs/ && \
    ln -s /usr/local/etc/nodejs/bin/node /usr/local/bin/node && \
    ln -s /usr/local/etc/nodejs/bin/npm /usr/local/bin/npm

## Update path
ENV PATH=/usr/local/etc/nodejs/bin:$PATH


# Install basic laravel php dependencies
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
