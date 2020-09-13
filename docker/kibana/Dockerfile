FROM node:10.22.0-alpine
#
# VARS
ENV KB_VER=7.9.1
# 
# Setup env and apt
RUN sed -i 's/dl-cdn/dl-2/g' /etc/apk/repositories && \
    apk -U --no-cache add \
            aria2 \
            curl && \
#
# Get and install packages
    cd /root/ && \
    mkdir -p /usr/share/kibana/ && \
    aria2c -s 16 -x 16 https://artifacts.elastic.co/downloads/kibana/kibana-$KB_VER-linux-x86_64.tar.gz && \
    tar xvfz kibana-$KB_VER-linux-x86_64.tar.gz --strip-components=1 -C /usr/share/kibana/ && \
#
# Kibana's bundled node does not work in alpine
    rm /usr/share/kibana/node/bin/node && \
    ln -s /usr/local/bin/node /usr/share/kibana/node/bin/node && \
#
# Setup user, groups and configs
    sed -i 's/#server.host: "localhost"/server.host: "0.0.0.0"/' /usr/share/kibana/config/kibana.yml && \
    sed -i 's/#elasticsearch.hosts: \["http:\/\/localhost:9200"\]/elasticsearch.hosts: \["https:\/\/elasticsearch:9200"\]/' /usr/share/kibana/config/kibana.yml && \
    echo "server.ssl.enabled: true" >> /usr/share/kibana/config/kibana.yml && \
    echo "server.ssl.certificate: /usr/share/kibana/config/certs/kibana/kibana.crt" >> /usr/share/kibana/config/kibana.yml && \
    echo "server.ssl.key: /usr/share/kibana/config/certs/kibana/kibana.key" >> /usr/share/kibana/config/kibana.yml && \
    echo "elasticsearch.ssl.certificateAuthorities: [ \"/usr/share/kibana/config/certs/ca/ca.crt\" ]" >> /usr/share/kibana/config/kibana.yml && \
    echo "elasticsearch.requestTimeout: 60000" >> /usr/share/kibana/config/kibana.yml && \
    echo "elasticsearch.shardTimeout: 60000" >> /usr/share/kibana/config/kibana.yml && \
#    echo "monitoring.enabled: false" >> /usr/share/kibana/config/kibana.yml && \ 
    echo "xpack.encryptedSavedObjects.encryptionKey: 01234567890123456789012345678901" >> /usr/share/kibana/config/kibana.yml && \
    echo "xpack.security.encryptionKey: 01234567890123456789012345678901" >> /usr/share/kibana/config/kibana.yml && \
    echo "xpack.reporting.encryptionKey: 01234567890123456789012345678901" >> /usr/share/kibana/config/kibana.yml && \
    chown -R 1000:1000 /usr/share/kibana/ && \
#
# Clean up
    apk del --purge aria2 && \
    rm -rf /root/* && \
    rm -rf /tmp/* && \
    rm -rf /var/cache/apk/*
#
# Healthcheck
HEALTHCHECK --retries=10 CMD curl -s -XGET 'https://127.0.0.1:5601'
#
# Start kibana
STOPSIGNAL SIGKILL
USER 1000:1000
CMD /usr/share/kibana/bin/kibana --elasticsearch.username=$ELASTICSEARCH_USERNAME --elasticsearch.password=$ELASTICSEARCH_PASSWORD
