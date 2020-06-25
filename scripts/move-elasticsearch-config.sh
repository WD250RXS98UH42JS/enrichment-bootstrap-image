#!/usr/bin/env sh

source /scripts/logger.sh

logger "INFO" "Moving default Elasticsearch config files to new place...";

mkdir -p ${ES_PATH_CONF} && cp -r /usr/share/elasticsearch/config/. ${ES_PATH_CONF} && rm -rf /usr/share/elasticsearch/config

if [ "$(ls -A ${ES_PATH_CONF}/)" ]; then
    logger "INFO" "Configuration files successfully moved.";
else
    logger "ERROR" "Configuration files wasn't moved.";
fi