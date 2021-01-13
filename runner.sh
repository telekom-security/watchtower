#!/bin/bash

# Got root?
myWHOAMI=$(whoami)
if [ "$myWHOAMI" != "root" ]
  then
    echo "### Need to run as root ..."
    echo
    exit
fi

### Define Slack-Watchman runner
fuSWRUN () {
local SLACK_WATCHMAN_NAME="$1"
local SLACK_WATCHMAN_TOKEN="$2"

# Changing the prefix will break logstash log ingestion
local SLACK_WATCHMAN_LOGFILE="slack_wm_$(echo $SLACK_WATCHMAN_NAME | tr -d " ").json"

# Options
## Timeframe: --timeframe {d,w,m,a}
## Query: [--users] [--channels] [--pii] [--financial] [--tokens] [--files] [--custom CUSTOM]
local SLACK_WATCHMAN_COMMAND="slack-watchman --timeframe a --all --output stdout | tee $SLACK_WATCHMAN_LOGFILE"

echo "### Now processing: $SLACK_WATCHMAN_NAME"
docker run -t --name runner \
              --rm \
              --read-only \
              -v /data/runner/log:/var/log/runner:rw \
              --env SLACK_WATCHMAN_TOKEN="$SLACK_WATCHMAN_TOKEN" \
              dtagdevsec/runner-wt:latest ash -c "$SLACK_WATCHMAN_COMMAND"

echo "### Done processing: $SLACK_WATCHMAN_NAME"
echo
}

# fuSWRUN "Workspace_Name" "OAuthToken"
fuSWRUN "Workspace_Name" "xoxp-1111111111111-2222222222222-3333333333333-44444444444444444444444444444444"
