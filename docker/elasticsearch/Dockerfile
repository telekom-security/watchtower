FROM alpine:3.12
#
# VARS
ENV ES_VER=7.9.1 \
    JAVA_HOME=/usr/lib/jvm/java-11-openjdk
# Include dist
ADD dist/ /root/dist/
#
# Setup env and apt
RUN sed -i 's/dl-cdn/dl-2/g' /etc/apk/repositories && \
    apk -U --no-cache add \
             aria2 \
             bash \
             curl \
             nss \
             openjdk11-jre \
             unzip && \
#
# Get and install packages
    cd /root/dist/ && \
    mkdir -p /usr/share/elasticsearch/ && \
    aria2c -s 16 -x 16 https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-$ES_VER-linux-x86_64.tar.gz && \
    tar xvfz elasticsearch-$ES_VER-linux-x86_64.tar.gz --strip-components=1 -C /usr/share/elasticsearch/ && \
#
# Add and move files
    cd /root/dist/ && \
    mkdir -p /usr/share/elasticsearch/config && \
    cp elasticsearch.yml /usr/share/elasticsearch/config/ && \
    cp instances.yml /usr/share/elasticsearch/config/ && \
    chmod 777 gen_cert.sh && \ 
    cp gen_cert.sh / && \
#
# Setup user, groups and configs
    addgroup -g 1000 elasticsearch && \
    adduser -S -H -s /bin/ash -u 1000 -D -g 1000 elasticsearch && \
    chown -R elasticsearch:elasticsearch /usr/share/elasticsearch/ && \
    rm -rf /usr/share/elasticsearch/modules/x-pack-ml && \
#
# Clean up
    apk del --purge aria2 && \
    rm -rf /root/* && \
    rm -rf /tmp/* && \
    rm -rf /var/cache/apk/*
#
# Healthcheck
HEALTHCHECK --retries=10 CMD curl --cacert /usr/share/elasticsearch/config/certs/ca/ca.crt -s https://127.0.0.1:9200 >/dev/null; if [[ $$? == 52 ]]; then echo 0; else echo 1; fi
#
# Start ELK
USER elasticsearch:elasticsearch
CMD /gen_cert.sh && exec /usr/share/elasticsearch/bin/elasticsearch
