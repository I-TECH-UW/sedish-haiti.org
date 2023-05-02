#!/bin/bash
###########################################
#
# Simple Shell script to clean/remove  opencr and  containers
#
# The script will 
#  - first stop the opencr and  containers 
#  - remove opencr and  containers
#  - remove opencr and  images
#  - remove opencr and  volumes
#

# stop opencr and  containers
echo '####################################################'
echo 'Stopping running opencr and  containers (if available)...'
echo '####################################################'
docker stop  opencr 

# remove  opencr and  stopped containers
echo '####################################################'
echo 'Removing opencr and  containers ..'
echo '####################################################'
docker rm opencr 


# remove  opencr and  images
echo '####################################################'
echo 'Removing  opencr and  images ...'
echo '####################################################'
docker rmi opencr 

# remove  opencr and  stray volumes if any
echo '####################################################'
echo 'Revoming  opencr and  container volumes (if any)'
echo '####################################################'
docker volume rm opencr 
