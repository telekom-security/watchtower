#!/bin/bash

# Vars
myPACKAGES="curl docker.io docker-compose git grc jq pwgen"
myINSTPATH="/opt/watchtower"
myGITREPO="https://github.com/t3chn0m4g3/watchtower"
myCRONJOBS="
# Run Slack-Watchman daily
0 6 * * *      root    /opt/watchtower/sw-runner.sh
"

# Installer
echo "### Watchtower Installer"
echo

# Got root?
myWHOAMI=$(whoami)
if [ "$myWHOAMI" != "root" ]
  then
    echo
    echo "### Need to run as root ..."
    echo
    exit
fi

# Do not run again if certificate bundle exists already
if [ -f /data/elastic/certs/bundle.zip ];
  then
    echo
    echo "### Certificate bundle already exists. Aborting."
    echo
    exit
fi

# Elasticsearch needs adjustments to kernel settings
myVM_MAX_MAP_COUNT=$(grep "vm.max_map_count" /etc/sysctl.conf)
if [ "$myVM_MAX_MAP_COUNT" == "" ];
  then
    echo
    echo "### Now patching sysctl.conf ..."
    echo
    echo "vm.max_map_count = 262144" | tee -a /etc/sysctl.conf 
    echo
    echo "### Reloading Kernel Parameter ..."
    echo
    sysctl -p
  else
    echo "$myVM_MAX_MAP_COUNT is already set."
    echo
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
    echo
    echo "### Need to install some missing packages ..."
    echo
    apt-get update -y
    for myDEPS in $myINST;
    do
      apt-get install $myDEPS -y
    done
  else
    echo
    echo "### All dependencies are met."
    echo
fi

# Check if cloned to /opt/watchtower
myPATH=$(pwd)
if [ "$myPATH" != "$myINSTPATH" ];
  then
    echo
    echo "### Watchtower needs to be installed into $myINSTPATH."
    echo "### Cloning and restarting setup from correct path."
    echo
    mkdir -p /opt
    cd /opt
    git clone $myGITREPO
    cd $myINSTPATH
    ./$0
    exit
fi

# Create folders
echo 
echo "### Creating folders ..."
echo
mkdir -vp /data/elastic/{certs,conf,log,data} \
          /data/slack-watchman
chmod -R 770 /data
chown -R 1000:0 /data

# Pull images
echo
echo "### Pulling docker images, please be patient."
echo
docker-compose -f docker/build.yml pull

# Start elasticsearch for the first time to gen certs and passwords
echo
echo "### Running Elasticsearch for the first time, please be patient while generating certificates and passwords."
echo
docker-compose -f docker/elasticsearch/docker-compose.yml up -d
docker logs -f elasticsearch 2>&1 | grep -m 1 "\[GREEN\]"
docker-compose -f docker/elasticsearch/docker-compose.yml down -v

# Convert passwords, so we can source them as vars
cat /data/elastic/conf/passwords | grep "PASSWORD" | cut -d " " -f 2- | tr -d " " > /data/elastic/conf/passwords.source
source /data/elastic/conf/passwords.source

# Replace passwords in docker-compose.yml, so Elastic Stack can start properly just out of the box
sed -i '/ELASTICSEARCH_USERNAME: kibana_system/!b;n;c\      ELASTICSEARCH_PASSWORD: '$kibana_system'' docker/docker-compose.yml
sed -i '/ELASTICSEARCH_USERNAME: elastic/!b;n;c\      ELASTICSEARCH_PASSWORD: '$elastic'' docker/docker-compose.yml
sed -i "s/ELASTICSEARCH_OBJECTS_ENCRYPTION_KEY.*$/ELASTICSEARCH_OBJECTS_ENCRYPTION_KEY: $(pwgen -cnsB 32 1)/" docker/docker-compose.yml
sed -i "s/ELASTICSEARCH_SECURITY_ENCRYPTION_KEY.*$/ELASTICSEARCH_SECURITY_ENCRYPTION_KEY: $(pwgen -cnsB 32 1)/" docker/docker-compose.yml
sed -i "s/ELASTICSEARCH_REPORTING_ENCRYPTION_KEY.*$/ELASTICSEARCH_REPORTING_ENCRYPTION_KEY: $(pwgen -cnsB 32 1)/" docker/docker-compose.yml

# Remove passwords in source format
rm /data/elastic/conf/passwords.source

# Add cronjob
myCHECK=$(grep "watchtower" /etc/crontab)
if [ "$myCHECK" == "" ];
  then
    echo
    echo "### Now adding cronjob ..."
    echo "$myCRONJOBS" | tee -a /etc/crontab
    echo
  else
    echo "### Cronjob is already set."
    echo
fi

# Ready to start and import objects
./start.sh
echo
echo "### Waiting for Kibana to be healthy."
echo -n "### Please be patient "
while true;
  do
    myCHECK=$(docker ps | grep kibana | grep healthy | wc -l)
    if [ "$myCHECK" == "1" ];
      then
	echo
        echo "### Kibana is alive."
	echo
        ./import_kibana-objects.sh elastic $elastic kibana-objects.tgz
        break
      else
        echo -n "."
        sleep 2
    fi
done

# Done
echo "### Kibana superuser: elastic / password: $elastic"
echo "### All generated passwords are stored in /data/elastic/conf/passwords."
echo "### Retrieve the passwords, store them in a safe place and delete the passwords file."
echo "### Done."
echo
