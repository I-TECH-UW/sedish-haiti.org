#!/bin/bash


# TEMP: Ensure the /tmp/backups folder exists
mkdir /tmp/backups

docker build \
    -t lnsp-mediator:local \
    -f projects/lnsp-mediator/Dockerfile \
    projects/lnsp-mediator \
    
# Build the Platform to contain the above custom builds
./build-image.sh

echo "You can run the the Platform commands: E.g: ./instant-linux package init -p dev"
