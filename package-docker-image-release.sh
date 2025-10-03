#!/bin/bash

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
   echo "HD Nexus Docker user is not provided"
   exit -1
else
   echo "HD Nexus Docker user is provided ok"
fi

if [ -z "$4" ]; then
   echo "HD Nexus Docker password is not provided"
   exit -1
else
   echo "HD Nexus Docker password is provided ok"
fi

if [ -z "$5" ]; then
   echo "HD Nexus Repo Server is not provided"
   exit -1
else
   echo "HD Nexus Repo Server is provided ok"
fi

docker login -u $1 -p $2
docker pull 192.168.1.193:30082/dmz:latest 
docker tag 192.168.1.193:30082/dmz:latest 192.168.1.193:30082/dmz:latest
docker push 192.168.1.193:30082/dmz:latest
docker tag 192.168.1.193:30082/dmz:latest 192.168.1.193:30082/dmz:latest

docker login -u $3 -p $4 $5
docker push 192.168.1.193:30082/dmz:latest
