#!/bin/bash
# Run this file to launch a Docker container

# Absolute path to this script, e.g. /home/user/bin/foo.sh
SCRIPTPATH=$(readlink -f "$0")
# Absolute path this script is in, thus /home/user/bin
PROJECTPATH=$(dirname "$SCRIPTPATH")

docker build -t quentincaffeino/apache-php-laravel:latest .

# Start bot container
docker run --rm -d \
    --name apache-php-laravel \
    -t quentincaffeino/apache-php-laravel:latest

docker exec -it apache-php-laravel bash
