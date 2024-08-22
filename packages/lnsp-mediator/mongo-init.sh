#!/bin/bash

# Substitute environment variables in mongo-init.js and execute it
envsubst < /docker-entrypoint-initdb.d/mongo-init-template.js > /docker-entrypoint-initdb.d/mongo-init.js

# Execute the MongoDB initialization script
mongo /docker-entrypoint-initdb.d/mongo-init.js