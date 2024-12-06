#!/bin/bash

# Number of instances
NUM_INSTANCES=${1:-10}  # Default to 3 if no argument is provided

# Base networks
NETWORKS="public reverse-proxy mysql"

# Start generating the compose file
cat <<EOF > docker-compose.yml
version: '3.9'

services:
EOF

# Generate service definitions
for i in $(seq 1 $NUM_INSTANCES); do
  SERVICE_NAME="isanteplus"
  if [ $i -gt 1 ]; then
    SERVICE_NAME="isanteplus$i"
  fi

  VOLUME_NAME="${SERVICE_NAME}-data"

  cat <<SERVICE >> docker-compose.yml
  $SERVICE_NAME:
    image: itechuw/docker-isanteplus-server:local
    build:
      context: .
      dockerfile: Dockerfile
    environment:
      - OMRS_JAVA_MEMORY_OPTS=\${OMRS_JAVA_MEMORY_OPTS}
      - OMRS_CONFIG_CONNECTION_SERVER=\${OMRS_CONFIG_CONNECTION_SERVER}
      - OMRS_CONFIG_CREATE_DATABASE_USER=\${OMRS_CONFIG_CREATE_DATABASE_USER}
      - OMRS_CONFIG_CREATE_TABLES=\${OMRS_CONFIG_CREATE_TABLES}
      - OMRS_CONFIG_ADD_DEMO_DATA=\${OMRS_CONFIG_ADD_DEMO_DATA}
      - OMRS_CONFIG_CONNECTION_URL=\${OMRS_CONFIG_CONNECTION_URL_$i}
      - OMRS_CONFIG_HAS_CURRENT_OPENMRS_DATABASE=\${OMRS_CONFIG_HAS_CURRENT_OPENMRS_DATABASE}
      - OMRS_JAVA_SERVER_OPTS=\${OMRS_JAVA_SERVER_OPTS}
      - OMRS_CONFIG_CONNECTION_USERNAME=\${OMRS_CONFIG_CONNECTION_USERNAME_$i}
      - OMRS_CONFIG_CONNECTION_PASSWORD=\${OMRS_CONFIG_CONNECTION_PASSWORD_$i}
      - OMRS_DEV_DEBUG_PORT=\${OMRS_DEV_DEBUG_PORT}
    volumes:
      - $VOLUME_NAME:/openmrs/data
      - /etc/timezone:/etc/timezone:ro
      - /etc/localtime:/etc/localtime:ro
    networks:
SERVICE

  # Add networks
  for NETWORK in $NETWORKS; do
    echo "      - $NETWORK" >> docker-compose.yml
  done

  # Add volume
  echo "" >> docker-compose.yml
done

# Add volume definitions
cat <<EOF >> docker-compose.yml
volumes:
EOF

for i in $(seq 1 $NUM_INSTANCES); do
  SERVICE_NAME="isanteplus"
  if [ $i -gt 1 ]; then
    SERVICE_NAME="isanteplus$i"
  fi
  VOLUME_NAME="${SERVICE_NAME}-data"

  echo "  $VOLUME_NAME:" >> docker-compose.yml
done

# Add network definitions
cat <<EOF >> docker-compose.yml
networks:
  public:
    external: true
    name: isanteplus_public
  mysql:
    external: true
    name: mysql_public
  reverse-proxy:
    name: reverse-proxy_public
    external: true
EOF
