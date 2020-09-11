#!/bin/bash
if [[ ! -f /data/elastic/certs/bundle.zip ]]; 
  then
    echo "First start, generating certs ..."
    /usr/share/elasticsearch/bin/elasticsearch-certutil cert --silent --pem --in /usr/share/elasticsearch/config/instances.yml -out /data/elastic/certs/bundle.zip;
    unzip /data/elastic/certs/bundle.zip -d /data/elastic/certs;
    chown -R 1000:1000 /data/elastic/certs
fi;
