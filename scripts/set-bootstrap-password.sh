#!/usr/bin/env sh

source /scripts/logger.sh

. "/scripts/move-elasticsearch-config.sh"

export ES_BIN_PATH=/usr/share/elasticsearch/bin

if [[ ! -f "${ES_PATH_CONF}/elasticsearch.keystore" ]]; then
    # Create keystore
    $ES_BIN_PATH/elasticsearch-keystore create;
    [[ -f "${ES_PATH_CONF}/elasticsearch.keystore" ]] && logger "INFO" "Keystore created successfully." || logger "ERROR" "Keystore not exist and wasn't created."

    # Changing Elasticsearch bootstrap user password
    printf "$ELASTIC_BOOTSTRAP_PASSWORD" | $ES_BIN_PATH/elasticsearch-keystore add --stdin "bootstrap.password"

else
    logger "INFO" "Passwords already configured, skipping configuration step."
fi;

logger "INFO" "$CONTAINER_NAME: Job done!"