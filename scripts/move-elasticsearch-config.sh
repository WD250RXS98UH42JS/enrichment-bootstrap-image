#!/usr/bin/env sh

source /scripts/logger.sh

logger "INFO" "Moving default Elasticsearch config files to new place...";

mkdir -p ${ES_PATH_CONF} && cp -r /usr/share/elasticsearch/config/. ${ES_PATH_CONF} && rm -rf /usr/share/elasticsearch/config

if [ "$(ls -A ${ES_PATH_CONF}/)" ]; then
    logger "INFO" "Configuration files successfully moved.";
else
    logger "ERROR" "Configuration files wasn't moved.";
fi

logger "INFO" "Creating symlink to certificates folder...";

[[ ! -f $ES_PATH_CONF/certs ]] && ln -sf $CERTS_DIR $ES_PATH_CONF/certs

if [[ -n "$(ls -la ${ES_PATH_CONF} | grep "\->")" ]]; then
    logger "INFO" "Symlink successfully created.";
else
    logger "ERROR" "Symlink wasn't created.";
fi