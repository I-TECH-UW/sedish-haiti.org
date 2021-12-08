#!/bin/bash

docker-compose -f docker-compose.ports.yml up certgen

docker-compose -f docker-compose.ports.yml up -d nginx openhim-core openhim-console mongo-db

sleep 10

docker-compose -f docker-compose.ports.yml up openhim-config

docker-compose -f docker-compose.ports.yml up -d shr-fhir opencr-fhir opencr-es kafka zookeeper

sleep 30

docker-compose -f docker-compose.ports.yml up -d shr opencr

sleep 30

docker-compose -f docker-compose.ports.yml logs shr opencr

collections=(
  'https://www.getpostman.com/collections/46fd37386092a9f460e4'
  'https://www.getpostman.com/collections/4d682cbb222bb538d365'
  'https://www.getpostman.com/collections/4f2328a2ce056ff876e4'
  'https://www.getpostman.com/collections/0d397620f00804b00d75'
)

for collection in ${collections[@]}; do
  echo $collection
  export POSTMAN_COLLECTION=$collection
  docker-compose -f docker-compose.ports.yml up newman
done
