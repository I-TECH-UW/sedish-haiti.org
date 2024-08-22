#!/bin/bash


# Build a Botswana Specific ElasticSearch instance
# TEMP: Ensure the /tmp/backups folder exists
mkdir /tmp/backups

docker build \
    -t docker.elastic.co/elasticsearch/elasticsearch:local \
    -f packages/analytics-datastore-elastic-search/Dockerfile \
    packages/analytics-datastore-elastic-search \
    --no-cache

docker build \
    -t xds-repo-api:local \
    -f projects/xds-repo-api/Dockerfile \
    projects/xds-repo-api \
    --no-cache
    
# Build the Platform to contain the above custom builds
./build-image.sh

echo "You can run the the Platform commands: E.g: ./instant-linux package init -p dev"
