#!/bin/bash
###########################################
#
# Simple Shell script to clean/remove  opencr and opencr-fhir containers
#
# The script will 
#  - first stop the opencr and opencr-fhir containers 
#  - remove opencr and opencr-fhir containers
#  - remove opencr and opencr-fhir images
#  - remove opencr and opencr-fhir volumes
#

# stop opencr and opencr-fhir containers
echo '####################################################'
echo 'Stopping running opencr and opencr-fhir containers (if available)...'
echo '####################################################'
docker stop  opencr opencr-fhir

# remove  opencr and opencr-fhir stopped containers
echo '####################################################'
echo 'Removing opencr and opencr-fhir containers ..'
echo '####################################################'
docker rm opencr opencr-fhir


# remove  opencr and opencr-fhir images
echo '####################################################'
echo 'Removing  opencr and opencr-fhir images ...'
echo '####################################################'
docker rmi opencr opencr-fhir

# remove  opencr and opencr-fhir stray volumes if any
echo '####################################################'
echo 'Revoming  opencr and opencr-fhir container volumes (if any)'
echo '####################################################'
docker volume rm opencr opencr-fhir
