#!/bin/bash

collections=(
  'https://www.getpostman.com/collections/46fd37386092a9f460e4'
  'https://www.getpostman.com/collections/4d682cbb222bb538d365'
  'https://www.getpostman.com/collections/4f2328a2ce056ff876e4'
  'https://www.getpostman.com/collections/0d397620f00804b00d75'
)

for collection in ${collections[@]}; do
  echo $collection
  export POSTMAN_COLLECTION=$collection
  sudo -E docker-compose -f docker-compose.ports.yml up newman
done