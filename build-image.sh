#!/bin/bash
TAG_NAME=${1:-latest}
docker build -t itechuw/sedish:"$TAG_NAME" .
