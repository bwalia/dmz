#!/bin/bash

set -x

TARGET_ENV_FILE=".env.dev"

if [ -z "$1" ]
  then
    echo "No env file path supplied"
    TARGET_ENV_NAME="dev"
else
    echo "Using .env file: $1"
    TARGET_ENV_NAME="$1"
    TARGET_ENV_FILE=".env.$1"
fi

if [ -f ${TARGET_ENV_FILE} ]; then
    echo "File ${TARGET_ENV_FILE} exists."
else 
    echo "File ${TARGET_ENV_FILE} does not exist."
exit 1
fi

if [ -z "$2" ]
  then
    echo "No docker image name supplied default to dmz"
    DOCKER_CONTAINER_NAME="dmz"
else
    echo "Docker image name: $2"
    DOCKER_CONTAINER_NAME="$2"
fi
if [ -z "$3" ]
  then
    echo "No JWT token supplied default to dmz"
    exit 1
else 
    JWT_TOKEN_KEY="$3"
fi

./build.sh $TARGET_ENV_NAME $DOCKER_CONTAINER_NAME $JWT_TOKEN_KEY
./bootstrap.sh $TARGET_ENV_NAME $DOCKER_CONTAINER_NAME $JWT_TOKEN_KEY

docker system prune -f
# --all --volumes
