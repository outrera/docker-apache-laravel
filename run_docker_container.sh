#!/bin/bash
# Run this file to launch a Docker container

CONTAINER_NAME=quentincaffeino/apache-laravel:latest

docker build -t $CONTAINER_NAME .

# Start bot container
docker run --rm -d \
  --name apache-laravel \
  -t $CONTAINER_NAME

docker exec -it $CONTAINER_NAME bash
