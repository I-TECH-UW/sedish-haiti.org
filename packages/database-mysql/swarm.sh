#!/bin/bash

ACTION=$1
MODE=$2

COMPOSE_FILE_PATH="$( cd "$(dirname "$0")" ; pwd -P )"
STACK_NAME=$(jq -r '.environmentVariables.SWARM_STACK_NAME' < "${COMPOSE_FILE_PATH}/package-metadata.json")

function init_vars() {
  export $(jq -r '.environmentVariables | to_entries|map("\(.key)=\(.value)")|.[]' "${COMPOSE_FILE_PATH}/package-metadata.json")
}

function deploy_stack() {
  docker stack deploy -c "${COMPOSE_FILE_PATH}/docker-compose.mysql.yml" "${STACK_NAME}"
}

function remove_stack() {
  docker stack rm "${STACK_NAME}"
}

init_vars

case "${ACTION}" in
  init|up)
    deploy_stack
    ;;
  down)
    docker service scale "${STACK_NAME}_${MYSQL_SERVICE_NAME}=0"
    ;;
  destroy)
    remove_stack
    ;;
  *)
    echo "Usage: $0 {init|up|down|destroy}"
    exit 1
    ;;
esac
