#!/bin/bash

# Got root?
myWHOAMI=$(whoami)
if [ "$myWHOAMI" != "root" ]
  then
    echo "### Need to run as root ..."
    echo
    exit
fi

echo "Stopping Watchtower docker services via docker-compose for maintenance."
docker-compose -f docker/docker-compose.yml down -v
