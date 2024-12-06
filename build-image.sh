#!/bin/bash


# TAG_NAME=${1:-latest}
# ENV_FILE=${2:-./.env.hie}

# set -o allexport; source "$ENV_FILE"; set +o allexport

# TAG_VERSION=${VERSION:-latest}
# PUSH=${2:-false}

# docker build -t itechuw/sedish-haiti:"$TAG_NAME" -t itechuw/sedish-haiti:"$TAG_VERSION" .

# if [ "$PUSH" = true ]; then
#   docker push itechuw/sedish-haiti:"$TAG_NAME"
#   docker push itechuw/sedish-haiti:"$TAG_VERSION"
# fi

#!/bin/bash
TAG_NAME=${1:-latest}

# We did not specify a tag so try and use the tag in the config.yaml if present
if [ -z "$1" ]; then
    # we grep out 'image: jembi/platform:2.x' from which we cut on : and choose the last column
    # this will always be the image tag or an empty string
    ImageTag=$(grep 'image:' ${PWD}/config.yaml | cut -d : -f 3)
    # only overwrite TAG_NAME if we have a tag present, and it's not just the base image name
    if [ -n "$ImageTag" ]; then
        TAG_NAME=${ImageTag}
    fi
fi

docker build -t itechuw/isanteplus-local:"$TAG_NAME" . --no-cache