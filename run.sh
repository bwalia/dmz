#!/bin/bash
# use deployto-docker.sh to build and deploy
echo "use deployto-docker.sh to build and deploy..."
bash deployto-docker.sh
exit 0

set -x

if [ -f .env.dev ]; then
    echo "File .env.dev exists."
else 
    echo "File .env.dev does not exist."
exit 1
fi

if [ -z "$1" ]
  then
    echo "No env file path supplied"
    TARGET_ENV_FILE=".env.dev"
else
    echo "Using .env file: $1"
    TARGET_ENV_FILE="$1"
fi

if [ -z "$2" ]
  then
    echo "No docker image name supplied default to dmz"
    DOCKER_CONTAINER_NAME="dmz"
else
    echo "Docker image name: $2"
    DOCKER_CONTAINER_NAME="$2"
fi

echo "Running docker-compose up -d."

DOCKER_COMPOSE_BIN=$(which docker-compose)

${DOCKER_COMPOSE_BIN} down --remove-orphans
${DOCKER_COMPOSE_BIN} --env-file ${TARGET_ENV_FILE}  up -d --build --remove-orphans

DOCKER_CONTAINER_NAME=""

docker exec -it ${DOCKER_CONTAINER_NAME} yarn build

docker exec -it ${DOCKER_CONTAINER_NAME} openresty -s reload

# replace app name in dashboard and other places to whitelabel the api gw
docker exec -it ${DOCKER_CONTAINER_NAME} "/usr/local/openresty/nginx/html/openresty-admin/.env"

docker system prune -f --all --volumes