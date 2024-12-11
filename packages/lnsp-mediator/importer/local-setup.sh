#!/bin/bash

# Resolve paths
IMPORTER_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
PARENT_DIR=$(cd "${IMPORTER_DIR}/.." && pwd)
PACKAGE_METADATA="${PARENT_DIR}/package-metadata.json"
ENV_FILE="${IMPORTER_DIR}/.env"

# Helper to load JSON values
function get_json_value() {
  local file=$1
  local key=$2
  jq -r ".environmentVariables.${key}" "${file}" 2>/dev/null
}

# Load environment variables
export MONGO_URL=${MONGO_URL:-$(grep -m1 'MONGO_URL=' "${ENV_FILE}" 2>/dev/null | cut -d '=' -f2 || get_json_value "${PACKAGE_METADATA}" "MONGO_URL")}
export MONGO_USERNAME=${MONGO_USERNAME:-$(grep -m1 'MONGO_USERNAME=' "${ENV_FILE}" 2>/dev/null | cut -d '=' -f2 || get_json_value "${PACKAGE_METADATA}" "MONGO_USERNAME")}
export MONGO_PASSWORD=${MONGO_PASSWORD:-$(grep -m1 'MONGO_PASSWORD=' "${ENV_FILE}" 2>/dev/null | cut -d '=' -f2 || get_json_value "${PACKAGE_METADATA}" "MONGO_PASSWORD")}

# Display resolved values (optional)
echo "Resolved environment variables:"
echo "  MONGO_URL=${MONGO_URL}"
echo "  MONGO_USERNAME=${MONGO_USERNAME}"
echo "  MONGO_PASSWORD=${MONGO_PASSWORD}"
