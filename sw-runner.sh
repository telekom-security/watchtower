#!/bin/bash

### Define Slack-Watchman runner
fuSWRUN () {
local SLACK_WATCHMAN_NAME="$1"
local SLACK_WATCHMAN_TOKEN="$2"
local SLACK_WATCHMAN_LOGFILE="$(echo $SLACK_WATCHMAN_NAME | tr -d " ").json"

# [--users] [--channels] [--pii] [--financial] [--tokens] [--files] [--custom CUSTOM]
local SLACK_WATCHMAN_QUERY="--all"
# --timeframe {d,w,m,a}
local SLACK_WATCHMAN_TIMEFRAME="--timeframe a"

echo -n "### Now running: $SLACK_WATCHMAN_NAME"
docker run --name slack-watchman \
           --rm \
           --read-only \
            -v /data/slack-watchman/log:/opt/slack-watchman/log:rw \
           --env SLACK_WATCHMAN_TOKEN="$SLACK_WATCHMAN_TOKEN" \
           --env SLACK_WATCHMAN_LOGFILE="$SLACK_WATCHMAN_LOGFILE" \
           --env SLACK_WATCHMAN_QUERY="$SLACK_WATCHMAN_QUERY" \
           --env SLACK_WATCHMAN_TIMEFRAME="$SLACK_WATCHMAN_TIMEFRAME" \
           ghcr.io/t3chn0m4g3/slack-watchman:latest
echo " - Done."
echo
}

# fuSWRUN "Workspace_Name" "OAuthToken"
fuSWRUN "slack_workspace" "xoxp-1111111111111-2222222222222-3333333333333-444be444444444444444444444444444"