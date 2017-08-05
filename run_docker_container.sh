#!/bin/bash
# Run this file to launch a Docker container

docker build -t quentincaffeino/apache-laravel:latest .

# Start bot container
docker run --rm -d \
    --name apache-laravel \
    -t quentincaffeino/apache-laravel:latest

docker exec -it apache-laravel bash
