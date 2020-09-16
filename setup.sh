#!/bin/bash

# Vars
myPACKAGES="curl docker.io docker-compose git grc pwgen"

# Got root?
myWHOAMI=$(whoami)
if [ "$myWHOAMI" != "root" ]
  then
    echo "### Need to run as root ..."
    exit
fi

# Can elasticsearch start without errors?
myVM_MAX_MAP_COUNT=$(grep "vm.max_map_count" /etc/sysctl.conf)
if [ "$myVM_MAX_MAP_COUNT" == "" ];
  then
    echo "### Now patching sysctl.conf ..."
    echo
    echo "vm.max_map_count = 262144" | tee -a /etc/sysctl.conf 
    echo
    echo "### Reloading Kernel Parameter ..."
    sysctl -p
  else
    echo "$myVM_MAX_MAP_COUNT is already set."
fi

# Check for deps
myINST=""
for myDEPS in $myPACKAGES;
do
  myOK=$(dpkg -s $myDEPS | head -n2 | grep ok | awk '{ print $3 }');
  if [ "$myOK" != "ok" ]
    then
      myINST=$(echo $myINST $myDEPS)
  fi
done
if [ "$myINST" != "" ]
  then
    echo "### Need to install some missing packages ..."
    apt-get update -y
    for myDEPS in $myINST;
    do
      apt-get install $myDEPS -y
    done
  else
    echo "All dependencies are met."
fi

exit

# Check path, we want /opt/watchtower
# Automatic install via GitHub
# Leave setup script in root and adjust paths accordingly
# fine tune docker-compose files (settings, paths, etc.)
# Replace token for Watchman
# Set alias (grc, dps)
# Set fancy prompt
# Push config to ELK (dashboards and stuff)
# Rename project to Slack-Watchtower



# Start elasticsearch for the first time to gen certs and passwords
echo "Running Elasticsearch for the first time, please be patient while generating certificates and passwords."
docker-compose -f elasticsearch/docker-compose.yml up -d
docker logs -f elasticsearch 2>&1 | grep -m 1 "Cluster health status changed from [YELLOW] to [GREEN]"
docker-compose -f elasticsearch/docker-compose.yml down -v

# Convert passwords, so we can source them as vars
cat /data/elastic/conf/passwords | grep "PASSWORD" | cut -d " " -f 2- | tr -d " " > /data/elastic/conf/passwords.source
source /data/elastic/conf/passwords.source

# Replace passwords in docker-compose.yml, so Elastic Stack can start properly just out of the box
sed -i '/ELASTICSEARCH_USERNAME: kibana_system/!b;n;c\      ELASTICSEARCH_PASSWORD: '$kibana_system'' docker-compose.yml
sed -i '/ELASTICSEARCH_USERNAME: elastic/!b;n;c\      ELASTICSEARCH_PASSWORD: '$elastic'' docker-compose.yml
sed -i "s/ELASTICSEARCH_OBJECTS_ENCRYPTION_KEY.*$/ELASTICSEARCH_OBJECTS_ENCRYPTION_KEY: $(pwgen -cnsB 32 1)/" docker-compose.yml
sed -i "s/ELASTICSEARCH_SECURITY_ENCRYPTION_KEY.*$/ELASTICSEARCH_SECURITY_ENCRYPTION_KEY: $(pwgen -cnsB 32 1)/" docker-compose.yml
sed -i "s/ELASTICSEARCH_REPORTING_ENCRYPTION_KEY.*$/ELASTICSEARCH_REPORTING_ENCRYPTION_KEY: $(pwgen -cnsB 32 1)/" docker-compose.yml

# Remove passwords in source format
rm /data/elastic/conf/passwords.source

# Done.
echo "Keep the passwords in a safe place and delete them afterwards from /data/elastic/conf/passwords."
