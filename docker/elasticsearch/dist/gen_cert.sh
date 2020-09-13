#!/bin/bash
if [[ ! -f /data/elastic/certs/bundle.zip ]]; 
  then
    echo "First start, generating certs ..."
    /usr/share/elasticsearch/bin/elasticsearch-certutil cert --silent --pem --in /usr/share/elasticsearch/config/instances.yml -out /usr/share/elasticsearch/config/certs/bundle.zip;
    unzip /usr/share/elasticsearch/config/certs/bundle.zip -d /usr/share/elasticsearch/config/certs;
    #chown -R 1000:0 /data/elastic/certs
fi;
