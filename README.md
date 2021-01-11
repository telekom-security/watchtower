# Watchtower

Watchtower uses the [Elastic Stack](https://www.elastic.co/products/) and [Slack-Watchman](https://github.com/PaperMtn/slack-watchman) by [@PaperMtn](https://github.com/PaperMtn).

Slack is a great tool for easy and convenient team collaboration and growing rapidly in popularity with home office becoming more widespread. As with other collaboration platforms, i.e. GitHub, it may happen that sensitive information get posted by accident or convenience while it should have never been posted.

Based on an adjustable ruleset Slack-Watchman will run on a daily basis and detect if and when sensitive information was posted and provide a permalink to the corresponding post for analysis.

Logstash will ingest the JSON based logfiles and feed them into an Elasticsearch index while a pre-configured Kibana dashboard will beautifully visualize all the captured detections.

![Watchtower](dashboard.png)

## Prerequisites
Watchtower can be installed on top of a previously installed Debian 10.x and will automatically download all required packages, such as ...
```
curl
docker.io
docker-compose
grc
jq
pwgen
```
Where possible the installation will be as less intrusive as possible. Only `/etc/crontab` and `/etc/sysctl.conf` will be adjusted to automatically run Slack-Watchman and prepare for a dockerized Elastic Stack.

## Setup
The following steps must be done as `root` (`su -`).

Clone this repository into `/opt/watchtower`:
```
git clone https://github.com/telekom-security/watchtower /opt/watchtower
```

Run the `setup.sh` script:
```
cd /opt/watchtower
./setup.sh
```

Please be patient during the setup procedure, all required docker images will be downloaded and started to generate all the necessary folders, passwords and certificates for the Elastic Stack. Once the configuration is completed the Elastic Stack will be started and the pre-configured Kibana objects imported so you can start right away.

Please store all the passwords in a safe place and delete the temporary password file from `/data/elastic/conf/passwords`.

## Configuration
You need to register Slack-Watchman as an app for your Slack workspace. Follow this [Requirements Guide](https://github.com/PaperMtn/slack-watchman#requirements) to successfully register your app in Slack and retrieve the required API token.

Once you retrieved the API token you simply add it the `sw-runner.sh`
```
# fuSWRUN "Workspace_Name" "OAuthToken"
fuSWRUN "slack_workspace" "xoxp-1111111111111-2222222222222-3333333333333-444be444444444444444444444444444"
```
The `Workspace_Name` is a name of your choosing and will determine the logfile name (*.json suffix will be added automatically).
The `OAuthToken` is the API token you will be provided via the Slack app settings.
Following this method you can add as many workspaces as you like and all will be monitored on a daily basis.

## Run Slack-Watchman
If this is a primary run with Slack-Watchman you can set the timeframe in `sw-runner.sh` to `--timeframe a` which is the default and will scan all past events. It's recommended however to change this to `--timeframe d` which will only scan the previous 24 hours.

For testing purposes you can run Slack-Watchman simply via `sw-runner.sh`. But keep in mind that each run will account against the API, once too hot your app will be put into cool off mode. Running once daily per registered Slack app is recommended.

## Licenses
The software Watchtower is built on uses the following licenses.
<br>GPLv3: [Github-Watchman](https://github.com/PaperMtn/github-watchman/blob/master/LICENSE)
<br>GPLv3: [Gitlab-Watchman](https://github.com/PaperMtn/gitlab-watchman/blob/master/LICENSE)
<br>GPLv3: [Slack-Watchman](https://github.com/PaperMtn/slack-watchman/blob/master/LICENSE)
<br>Apache 2 License: [elasticsearch](https://github.com/elasticsearch/elasticsearch/blob/master/LICENSE.txt), [logstash](https://github.com/elasticsearch/logstash/blob/master/LICENSE), [kibana](https://github.com/elasticsearch/kibana/blob/master/LICENSE.md), [docker](https://github.com/docker/docker/blob/master/LICENSE)
<br> Other: [Debian licensing](https://www.debian.org/legal/licenses/)

