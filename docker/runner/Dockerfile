FROM alpine:3.12
#
# Install packages
RUN sed -i 's/dl-cdn/dl-2/g' /etc/apk/repositories && \
    apk -U add \
             build-base \
             git \
	     py3-colorama \
	     py3-yaml \
	     py3-requests \
	     py3-termcolor \
             python3 \
             python3-dev && \
    mkdir -p /var/log/runner && \
    cd /root && \
#
# Build Slack-Watchman
    git clone https://github.com/PaperMtn/slack-watchman -b 3.0.10 && \
    cd slack-watchman && \
    chmod 700 setup.py && \
    python3 setup.py install && \
#
# Build Github-Watchman
    cd /root && \
    git clone https://github.com/PaperMtn/github-watchman -b 1.0.1 && \
    cd github-watchman && \
    chmod 700 setup.py && \
    python3 setup.py install && \
#
# Build Gitlab-Watchman
    cd /root && \
    git clone https://github.com/PaperMtn/gitlab-watchman -b 1.4.0 && \
    cd gitlab-watchman && \
    chmod 700 setup.py && \
    python3 setup.py install && \
#
# Clean up
    apk del --purge build-base \
                    git \
		    python3-dev && \
    rm -rf /root/* && \
    rm -rf /var/cache/apk/*
#
STOPSIGNAL SIGINT
WORKDIR /var/log/runner
