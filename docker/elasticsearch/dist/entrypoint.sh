#!/bin/bash
# If this is the first start of elastic search we need to generate certificates and users
if [[ ! -f /data/elastic/certs/bundle.zip ]]; 
  then
    echo "First start, generating certs ..."
    /usr/share/elasticsearch/bin/elasticsearch-certutil cert --silent --pem --in /usr/share/elasticsearch/config/instances.yml -out /usr/share/elasticsearch/config/certs/bundle.zip;
    unzip /usr/share/elasticsearch/config/certs/bundle.zip -d /usr/share/elasticsearch/config/certs;
    /usr/share/elasticsearch/bin/elasticsearch &
    while true;
      do
        curl --cacert /usr/share/elasticsearch/config/certs/ca/ca.crt -s https://127.0.0.1:9200
	if [[ $? == 0 ]];
	  then
            break
	fi
	sleep 2
    done
    echo "Elasticsearch is up, now setting up account passwords ..."
    /usr/share/elasticsearch/bin/elasticsearch-setup-passwords auto --batch --url https://elasticsearch:9200 > /data/elastic/conf/passwords
    # In order for the setup to work we need to await termination after first start
    echo "Done. Waiting for termination..."
    exit
fi;

# Regular start of elasticsearch
exec /usr/share/elasticsearch/bin/elasticsearch
