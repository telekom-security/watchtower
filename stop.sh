#!/bin/bash
echo "Stopping Watchtower docker services via docker-compose for maintenance."
docker-compose -f docker/docker-compose.yml down -v
