#!/usr/bin/env sh

source /scripts/logger.sh

. "/scripts/move-elasticsearch-config.sh"

ln -sf $CERTS_DIR $ES_PATH_CONF/certs

while [[ ! -f ${ES_PATH_CONF}/certs/ca/ca.crt ]]
do
    logger "INFO" "Waiting for CA to be created..."
    sleep 3
done

if [[ ! -f ${ES_PATH_CONF}/certs/${POD_NAME}/${POD_NAME}.zip ]]; then
    # Generating certificates
    mkdir -p ${ES_PATH_CONF}/certs/${POD_NAME} && \
    /usr/share/elasticsearch/bin/elasticsearch-certutil cert --pem \
                                                             --ca ${ES_PATH_CONF}/certs/ca/ca.p12 \
                                                             --ca-pass "" \
                                                             --out ${ES_PATH_CONF}/certs/${POD_NAME}/${POD_NAME}.zip \
                                                             --name "${POD_NAME}" \
                                                             --ip "${POD_IP}" \
                                                             --dns "${POD_NAME}" \
                                                             --silent
    # Check if certificates was generated properly
    if [[ -f ${ES_PATH_CONF}/certs/${POD_NAME}/${POD_NAME}.zip ]]; then
        unzip -o ${ES_PATH_CONF}/certs/${POD_NAME}/${POD_NAME}.zip -d ${ES_PATH_CONF}/certs && logger "INFO" "Certificates was generated successfully."
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