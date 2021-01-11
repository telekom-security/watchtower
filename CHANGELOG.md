# Changelog

# 20210111
## Add Slack-Watchman 3.0.10
Slack-Watchman 3.0.10 uses different field names which will require you to download `watchtower_kibana_objects.ndjson.zip` and import it into Kibana.
All Kibana objects were adjusted accordingly.

## Update Elastic Stack to 7.10.1
There might be breaking changes, if in doubt do not upgrade (`git pull`).

## Integration of Github and Gitlab Watchman
I just started to integrate Github- and Gitlab Watchman into the Docker image, no ELK or runnter integration yet (todo).

