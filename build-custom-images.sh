#!/bin/bash


# Ensure required directories exist for volume mapping
if [ ! -d "/tmp/backups" ]; then
  mkdir /tmp/backups
fi
if [ ! -d "/var/lib/db-volume/mysql" ]; then
  mkdir -p /var/lib/db-volume/mysql
  chmod +w /var/lib/db-volume/mysql
fi
if [ ! -d "/var/lib/openmrs-volume/openmrs-data" ]; then
  mkdir -p /var/lib/openmrs-volume/openmrs-data
  chmod +w /var/lib/openmrs-volume/openmrs-data
fi

##
# iSantePlus DB
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

##
# iSantePlus Application
## 

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



## Build the Platform to contain the above custom builds
./build-image.sh

echo "You can run the the Platform commands: E.g: ./instant-linux package init -p dev"
