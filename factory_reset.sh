#!/bin/bash

# Got root?
myWHOAMI=$(whoami)
if [ "$myWHOAMI" != "root" ]
  then
    echo "### Need to run as root ..."
    exit
fi

# Clear all settings, files, passwords, certs for Slack-Watchtower
echo "### Now removing all contents of /data."
echo "### This cannot be undone."
rm -rI /data/elastic /data/watchtower

# Replace passwords in docker-compose.yml with CHANGEME
sed -i '/ELASTICSEARCH_USERNAME: kibana_system/!b;n;c\      ELASTICSEARCH_PASSWORD: CHANGEME' docker/docker-compose.yml
sed -i '/ELASTICSEARCH_USERNAME: elastic/!b;n;c\      ELASTICSEARCH_PASSWORD: CHANGEME' docker/docker-compose.yml
sed -i "s/ELASTICSEARCH_OBJECTS_ENCRYPTION_KEY.*$/ELASTICSEARCH_OBJECTS_ENCRYPTION_KEY: CHANGEME/" docker/docker-compose.yml
sed -i "s/ELASTICSEARCH_SECURITY_ENCRYPTION_KEY.*$/ELASTICSEARCH_SECURITY_ENCRYPTION_KEY: CHANGEME/" docker/docker-compose.yml
sed -i "s/ELASTICSEARCH_REPORTING_ENCRYPTION_KEY.*$/ELASTICSEARCH_REPORTING_ENCRYPTION_KEY: CHANGEME/" docker/docker-compose.yml
