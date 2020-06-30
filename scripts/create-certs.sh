#!/usr/bin/env sh

source /scripts/logger.sh

. "/scripts/move-elasticsearch-config.sh"

ln -sf $CERTS_DIR $ES_PATH_CONF/certs

if [[ ! -f ${ES_PATH_CONF}/certs/bundle.zip ]]; then
    # Generating certificates
    /usr/share/elasticsearch/bin/elasticsearch-certutil cert --silent --pem --in ${ES_PATH_CONF}/instances.yml -out ${ES_PATH_CONF}/certs/bundle.zip;
    # Check if certificates was generated properly
    if [[ -f ${ES_PATH_CONF}/certs/bundle.zip ]]; then
        unzip -o ${ES_PATH_CONF}/certs/bundle.zip -d ${ES_PATH_CONF}/certs && logger "INFO" "Certificates was generated successfully."
        logger "INFO" "Certificates was generated successfully."
    else
        logger "ERROR" "Certificates wasn't generated."
    fi
else
    logger "INFO" "Certificates are already exists, skipping creation step."
fi

chown -R 1000:1000 $CERTS_DIR;
chmod -R 770 $CERTS_DIR;
chown -R 1000:1000 /usr/share/elasticsearch/data;

logger "INFO" "$CONTAINER_NAME: Job done!"