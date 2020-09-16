#!/bin/bash
echo "Starting Watchtower docker services via docker-compose. This usually only needs to be done once or after maintenance."
docker-compose -f docker/docker-compose.yml up -d
