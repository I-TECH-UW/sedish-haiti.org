#!/bin/bash

declare ACTION=""
declare MODE=""
declare COMPOSE_FILE_PATH=""
declare UTILS_PATH=""
declare STACK="mysql"

function init_vars() {
  ACTION=$1
  MODE=$2

  COMPOSE_FILE_PATH=$(
    cd "$(dirname "${BASH_SOURCE[0]}")" || exit
    pwd -P
  )

  UTILS_PATH="${COMPOSE_FILE_PATH}/../utils"

  # Load environment variables from package-metadata.json if present
  if [ -f "${COMPOSE_FILE_PATH}/package-metadata.json" ]; then
    export $(jq -r '.environmentVariables | to_entries|map("\(.key)=\(.value)")|.[]' "${COMPOSE_FILE_PATH}/package-metadata.json")
  fi

  readonly ACTION
  readonly MODE
  readonly COMPOSE_FILE_PATH
  readonly UTILS_PATH
  readonly STACK
}

# shellcheck disable=SC1091
function import_sources() {
  source "${UTILS_PATH}/docker-utils.sh"
  source "${UTILS_PATH}/config-utils.sh"
  source "${UTILS_PATH}/log.sh"
}

function initialize_package() {
  local mysql_dev_compose_filename=""

  # Ensure the bind mount directory exists
  HOST_DATA_DIR="/home/ubuntu/db"
  if [ ! -d "$HOST_DATA_DIR" ]; then
    log info "Creating directory for MySQL data: $HOST_DATA_DIR"
    mkdir -p "$HOST_DATA_DIR"
    # Adjust permissions as needed, e.g.:
    # chown 1001:1001 "$HOST_DATA_DIR"
  fi

  if [ "${MODE}" == "dev" ]; then
    log info "Running package in DEV mode"
    mysql_dev_compose_filename="docker-compose.dev.yml"
  else
    log info "Running package in PROD mode"
  fi

  (
    # Deploy the MySQL service using the base compose file and optionally the dev file
    docker::deploy_service "$STACK" "${COMPOSE_FILE_PATH}" "docker-compose.yml" "" "$mysql_dev_compose_filename"
  ) ||
    {
      log error "Failed to deploy package"
      exit 1
    }
}

function destroy_package() {
  docker::stack_destroy "$STACK"
  docker::prune_configs "mysql"
}

main() {
  init_vars "$@"
  import_sources

  if [[ "${ACTION}" == "init" ]] || [[ "${ACTION}" == "up" ]]; then
    initialize_package
  elif [[ "${ACTION}" == "down" ]]; then
    log info "Scaling down package"
    docker::scale_services "$STACK" 0
  elif [[ "${ACTION}" == "destroy" ]]; then
    log info "Destroying package"
    destroy_package
  else
    log error "Valid options are: init, up, down, or destroy"
  fi
}

main "$@"
