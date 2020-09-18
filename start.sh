#!/bin/bash

# Got root?
myWHOAMI=$(whoami)
if [ "$myWHOAMI" != "root" ]
  then
    echo "### Need to run as root ..."
    echo
    exit
fi

echo "Starting Watchtower docker services via docker-compose. This usually only needs to be done once or after maintenance."
docker-compose -f docker/docker-compose.yml up -d
