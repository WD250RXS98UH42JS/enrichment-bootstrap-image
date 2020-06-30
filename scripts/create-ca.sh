#!/usr/bin/env sh

source /scripts/logger.sh

. "/scripts/move-elasticsearch-config.sh"

ln -sf $CERTS_DIR $ES_PATH_CONF/certs

if [[ ! -f ${ES_PATH_CONF}/certs/ca/ca.crt ]]; then
    # Generating CA
    mkdir -p ${ES_PATH_CONF}/certs/ca && \
    /usr/share/elasticsearch/bin/elasticsearch-certutil ca --silent --out ${ES_PATH_CONF}/certs/ca/ca.p12 --pass "" && \
    openssl pkcs12 -in ${ES_PATH_CONF}/certs/ca/ca.p12 -clcerts -nokeys -out ${ES_PATH_CONF}/certs/ca/ca.crt -passin 'pass:'
    # Check if CA was generated properly
    if [[ -f ${ES_PATH_CONF}/certs/ca/ca.crt ]]; then
        logger "INFO" "CA was generated successfully."
    else
        logger "ERROR" "CA wasn't generated."
    fi
else
    logger "INFO" "CA already exists, skipping creation step."
fi

chown -R 1000:1000 $CERTS_DIR;
chmod -R 770 $CERTS_DIR;

logger "INFO" "$CONTAINER_NAME: Job done!"