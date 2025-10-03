#!/bin/bash

echo "Building the docker image"

docker build -t 192.168.1.193:30082/dmz .
