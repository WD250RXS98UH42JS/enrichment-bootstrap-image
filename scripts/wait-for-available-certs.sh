#!/usr/bin/env sh

source /scripts/logger.sh

while [[ ! -f ${CERTS_DIR}/ca/ca.crt ]]
do
    logger "INFO" "Waiting for certs to be created..."
    sleep 3
done

logger "INFO" "$CONTAINER_NAME: Job done!"