#!/bin/bash

declare ACTION=""
declare MODE=""
declare COMPOSE_FILE_PATH=""
declare UTILS_PATH=""
declare STACK="lnsp-mediator"
declare MONGO_STACK="lnsp-mongo"

function init_vars() {
  ACTION=$1
  MODE=$2

  COMPOSE_FILE_PATH=$(
    cd "$(dirname "${BASH_SOURCE[0]}")" || exit
    pwd -P
  )

  UTILS_PATH="${COMPOSE_FILE_PATH}/../utils"

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
  local mongo_cluster_compose_filename=""
  local mongo_dev_compose_filename=""
  local xds_dev_compose_filename=""

  if [[ "${MODE}" == "dev" ]]; then
    log info "Running package in DEV mode"
    mongo_dev_compose_filename="docker-compose-mongo.dev.yml"
    xds_dev_compose_filename="docker-compose.dev.yml"
  else
    log info "Running package in PROD mode"
  fi

  if [[ "${CLUSTERED_MODE}" == "true" ]]; then
    mongo_cluster_compose_filename="docker-compose-mongo.cluster.yml"
  fi

  (
    # If DB does not exist, bring up Mongo stack on init/up
    if [[ "${LNSP_DB_EXISTS}" != "true" ]]; then
      if [[ "${ACTION}" == "init" || "${ACTION}" == "up" ]]; then
        docker::deploy_service "${MONGO_STACK}" "${COMPOSE_FILE_PATH}" "docker-compose-mongo.yml" \
          "$mongo_cluster_compose_filename" "$mongo_dev_compose_filename"
      fi
    else
      log info "LNSP_DB_EXISTS=true, assuming Mongo is already running."
    fi

    log info "Waiting for Mongo to be ready..."
    config::await_service_running "lnsp-mongo-1" "${COMPOSE_FILE_PATH}/docker-compose.await-helper-mongo.yml" "1" "$MONGO_STACK"
    
    # If run_migrations is true and action is init or up, run migrations
    if [[ "${LNSP_RUN_MIGRATIONS}" == "true" && ( "${ACTION}" == "init" || "${ACTION}" == "up" ) ]]; then
      log info "LNSP_RUN_MIGRATIONS=true, running MongoDB migrations..."

      #docker::deploy_config_importer $STACK "${COMPOSE_FILE_PATH}/importer/docker-compose.migrate.yml" "mongo-migrate" "lnsp-mediator"
      docker::deploy_service $STACK "${COMPOSE_FILE_PATH}/importer/" "docker-compose.migrate.yml"
    else
      log info "LNSP_RUN_MIGRATIONS=false or not init/up action, skipping migrations."
    fi

    # Deploy main application services after waiting for DB and running migrations (if any)
    docker::deploy_service $STACK "${COMPOSE_FILE_PATH}" "docker-compose.yml" "$xds_dev_compose_filename"
  ) || {
    log error "Failed to deploy package"
    exit 1
  }
}

function destroy_package() {
  # If the DB does not exist, we manage stacks fully
  if [[ "${LNSP_DB_EXISTS}" != "true" ]]; then
    docker::stack_destroy "$STACK"
    if [[ "${CLUSTERED_MODE}" == "true" ]]; then
      log warn "Volumes are only deleted on the host on which the command is run. Mongo volumes on other nodes are not deleted"
    fi
    docker::stack_destroy "$MONGO_STACK"
  else
    log info "LNSP_DB_EXISTS=true, not destroying DB stack, only destroying lnsp services."
    docker::stack_destroy "$STACK"
  fi

  docker::prune_configs "lnsp-mediator"
}

main() {
  init_vars "$@"
  import_sources

  if [[ "${ACTION}" == "init" || "${ACTION}" == "up" ]]; then
    if [[ "${CLUSTERED_MODE}" == "true" ]]; then
      log info "Running package in Cluster node mode"
    else
      log info "Running package in Single node mode"
    fi

    initialize_package
  elif [[ "${ACTION}" == "down" ]]; then
    log info "Scaling down package"
    docker::scale_services "$STACK" 0
    # Only scale down mongo services if DB does not exist
    if [[ "${LNSP_DB_EXISTS}" != "true" ]]; then
      docker::scale_services "$MONGO_STACK" 0
    fi
  elif [[ "${ACTION}" == "destroy" ]]; then
    log info "Destroying package"
    destroy_package
  else
    log error "Valid options are: init, up, down, or destroy"
  fi
}

main "$@"
