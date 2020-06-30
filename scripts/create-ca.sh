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
    # Adding CA to truststore
    truststore_status=$(echo yes | keytool -import -alias caelk -file ${ES_PATH_CONF}/certs/ca/ca.crt -keystore ${ES_PATH_CONF}/certs/truststore.jks -storepass 'changeit' | grep keystore | cut -d" " -f4)
    if [[ $truststore_status -eq 1 ]]; then
        logger "INFO" "CA was successfully added to truststore."
    else
        logger "ERROR" "CA wasn't added to truststore."
    fi
else
    logger "INFO" "CA already exists, skipping creation step."
fi

chown -R 1000:1000 $CERTS_DIR;
chmod -R 770 $CERTS_DIR;

logger "INFO" "$CONTAINER_NAME: Job done!"