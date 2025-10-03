#!/bin/bash

set -x

USERNAME="$1"
PASSWD="$2"
TARGET_ENV="$3"

rm -Rf .env
rm -Rf /tmp/.env_cypress
echo "" > /tmp/.env_cypress
echo "CYPRESS_LOGIN_EMAIL=$USERNAME" >> /tmp/.env_cypress
echo "CYPRESS_LOGIN_PASSWORD=$PASSWD" >> /tmp/.env_cypress
echo "CYPRESS_TARGET_ENV=$TARGET_ENV" >> /tmp/.env_cypress
if [ "$TARGET_ENV" = "test" ]; then
    BASE_URL="https://dmz.dev.kubes.healthdata.be"
    FRONTEND_URL="https://test-front.kubes.healthdata.be"
    NODEAPP_ORIGIN_HOST="172.177.0.10:3009"
    SERVER_NAME="test-front.kubes.healthdata.be"
    TARGET_PLATFORM="docker"
fi
if [ "$TARGET_ENV" = "local" ]; then
    BASE_URL="http://host.docker.internal:8080"
    FRONTEND_URL="http://host.docker.internal:8000"
    NODEAPP_ORIGIN_HOST="172.177.0.10:3009"
    SERVER_NAME="host.docker.internal"
    TARGET_PLATFORM="docker"
fi
sleep 2
echo "CYPRESS_BASE_PUB_URL=$BASE_URL" >> /tmp/.env_cypress
echo "CYPRESS_FRONTEND_URL=$FRONTEND_URL" >> /tmp/.env_cypress
echo "CYPRESS_NODEAPP_ORIGIN_HOST=$NODEAPP_ORIGIN_HOST" >> /tmp/.env_cypress
echo "CYPRESS_SERVER_NAME=$SERVER_NAME" >> /tmp/.env_cypress
echo "CYPRESS_TARGET_PLATFORM=$TARGET_PLATFORM" >> /tmp/.env_cypress

echo "" >> /tmp/.env_cypress

mv /tmp/.env_cypress .env
cat .env
docker compose -f docker-compose-cypress.yml up
