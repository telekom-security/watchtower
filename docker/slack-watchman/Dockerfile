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
    mkdir -p /opt/slack-watchman/log && \
    cd /root && \
#
# Build Slack-Watchman
    git clone https://github.com/PaperMtn/slack-watchman -b develop && \
    cd slack-watchman && \
    chmod 700 setup.py && \
    git checkout ab1a80bfadbd70e1de4c3a43b1434f22d4270369 && \
    sed -i 's/"type": "%(type)s"/"detection.type": "%(type)s"/' slack_watchman/logger.py && \
# Setup Slack-Watchman
    python3 setup.py install && \
#
# Clean up
    apk del --purge build-base \
                    git \
		    python3-dev && \
    rm -rf /root/* && \
    rm -rf /var/cache/apk/*
#
# Run Slack-Watchman
STOPSIGNAL SIGINT
WORKDIR /opt/slack-watchman/
#CMD slack-watchman $SLACK_WATCHMAN_TIMEFRAME $SLACK_WATCHMAN_QUERY --output stdout | sed 's#matching: \"#matching: \\"#' | sed 's#""}$#\\""}#' > $SLACK_WATCHMAN_LOGFILE
CMD slack-watchman $SLACK_WATCHMAN_TIMEFRAME $SLACK_WATCHMAN_QUERY --output stdout > $SLACK_WATCHMAN_LOGFILE
