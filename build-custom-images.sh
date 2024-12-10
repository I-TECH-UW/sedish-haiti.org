#!/bin/bash


# TEMP: Ensure the /tmp/backups folder exists
mkdir /tmp/backups

docker build \
    -t lnsp-mediator:local \
    -f projects/lnsp-mediator/Dockerfile \
    projects/lnsp-mediator \

# Load Env vars from json file environmentVariables field
filepath="./packages/emr-isanteplus/package-metadata.json"
envs=$(jq -r '.environmentVariables | to_entries | .[] | "\(.key)=\(.value)"' $filepath)

# Export each environment variable
while IFS= read -r line; do
  export "$line"
done <<< "$envs"

docker compose \
    -f packages/emr-isanteplus/docker-compose.yml \
    build


##
# Isanteplus DB
##
# Load Env vars from package-metadata.json file
filepath="./packages/database-mysql/package-metadata.json"
envs=$(jq -r '.environmentVariables | to_entries | .[] | "\(.key)=\(.value)"' $filepath)

# Export each environment variable
while IFS= read -r line; do
  export "$line"
done <<< "$envs"

# Build the Docker image
docker build -t isanteplus-mysql:5.7.44 ./projects/isanteplus-db

# Build the Platform to contain the above custom builds
./build-image.sh

echo "You can run the the Platform commands: E.g: ./instant-linux package init -p dev"
