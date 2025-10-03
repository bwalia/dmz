#!/bin/bash

set -x
if [ -z "$1" ]; then
   echo "Docker username is not provided"
   exit -1
else
   echo "Docker username is provided ok"
fi
if [ -z "$2" ]; then
   echo "Docker password is not provided"
   exit -1
else
   echo "Docker password is provided ok"
fi

if [ -z "$3" ]; then
   echo "Cluster is not provided"
   exit -1
else
   echo "Cluster is provided ok"
fi

if [ -z "$4" ]; then
   echo "Env is not provided"
   exit -1
else
   echo "Env is provided ok"
fi

DOCKER_PUBLIC_IMAGE_NAME=hd-docker/dmz
VERSION=latest
#SOURCE_IMAGE=openresty_alpine

echo "Running docker-compose up -d."

docker compose up -d --build --remove-orphans

DOCKER_CONTAINER_NAME="dmz"

docker exec -it ${DOCKER_CONTAINER_NAME} yarn build
docker exec -it ${DOCKER_CONTAINER_NAME} openresty -s reload

#docker build -t 192.168.1.193:30082/${DOCKER_CONTAINER_NAME}:latest  -f Dockerfile . --no-cache
#docker push 192.168.1.193:30082/${DOCKER_CONTAINER_NAME}:latest
#  docker build -t 192.168.1.193:30082/${DOCKER_CONTAINER_NAME}:latest --build-arg RESTY_FAT_IMAGE_BASE="openresty/openresty" --build-arg RESTY_FAT_IMAGE_TAG=alpine -f Dockerfile . --no-cache
docker buildx build --push -t 192.168.1.193:30082/${DOCKER_CONTAINER_NAME}:latest .


helm upgrade -i node-app ./devops/helm-charts/node-app/ -f devops/helm-charts/node-app/values-k3s1.yaml

helm uninstall hd-front-gw-$4 -n $4
helm uninstall hd-api-gw-$4 -n $4
helm upgrade -i hd-api-gw-$4 ./devops/helm-charts/dmz -f devops/helm-charts/dmz/values-$4-api-bpa.yaml --set TARGET_ENV=$4 --namespace $4 --create-namespace
kubectl rollout restart deployment dmz-api-$4 -n $4
sleep 30
helm upgrade -i hd-front-gw-$4 ./devops/helm-charts/dmz -f devops/helm-charts/dmz/values-$4-front-bpa.yaml --set TARGET_ENV=$4 --namespace $4 --create-namespace
kubectl rollout restart deployment dmz-front-api-$4 -n $4

watch "kubectl get ing,pods -n $4"