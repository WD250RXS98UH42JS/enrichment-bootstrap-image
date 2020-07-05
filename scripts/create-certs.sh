#!/usr/bin/env sh

source /scripts/logger.sh

. "/scripts/move-elasticsearch-config.sh"

# [[ ! -f $ES_PATH_CONF/certs ]] && ln -sf $CERTS_DIR $ES_PATH_CONF/certs

# while [[ ! -f ${ES_PATH_CONF}/certs/ca/ca.crt ]]
# do
#     logger "INFO" "Waiting for CA to be created..."
#     sleep 3
# done

# if [[ ! -f ${ES_PATH_CONF}/certs/${POD_NAME}/${POD_NAME}.zip ]]; then
#     # Generating certificates
#     mkdir -p ${ES_PATH_CONF}/certs/${POD_NAME} && \
#     /usr/share/elasticsearch/bin/elasticsearch-certutil cert --pem \
#                                                              --ca ${ES_PATH_CONF}/certs/ca/ca.p12 \
#                                                              --ca-pass "" \
#                                                              --out ${ES_PATH_CONF}/certs/${POD_NAME}/${POD_NAME}.zip \
#                                                              --name "${POD_NAME}" \
#                                                              --silent
#     # Check if certificates was generated properly
#     if [[ -f ${ES_PATH_CONF}/certs/${POD_NAME}/${POD_NAME}.zip ]]; then
#         unzip -o ${ES_PATH_CONF}/certs/${POD_NAME}/${POD_NAME}.zip -d ${ES_PATH_CONF}/certs && \
#         logger "INFO" "Certificates was generated successfully."
#     else
#         logger "ERROR" "Certificates wasn't generated."
#     fi
# else
#     logger "INFO" "Certificates are already exists, skipping creation step."
# fi

if [[ ! -f ${ES_PATH_CONF}/certs/bundle.zip ]]; then
    # Generating certificates
    # /usr/share/elasticsearch/bin/elasticsearch-certutil cert --silent --pem --in ${ES_PATH_CONF}/instances.yml -out ${ES_PATH_CONF}/certs/bundle.zip;
    /usr/share/elasticsearch/bin/elasticsearch-certutil cert --silent --pem --keep-ca-key --in ${ES_PATH_CONF}/instances.yml -out ${ES_PATH_CONF}/certs/bundle.zip;
    # Check if certificates was generated properly
    if [[ -f ${ES_PATH_CONF}/certs/bundle.zip ]]; then
        unzip -o ${ES_PATH_CONF}/certs/bundle.zip -d ${ES_PATH_CONF}/certs && \
        logger "INFO" "Certificates was generated successfully."
         /usr/share/elasticsearch/bin/elasticsearch-certgen http --cert ${ES_PATH_CONF}/certs/ca/ca.crt --key ${ES_PATH_CONF}/certs/ca/ca.key --silent --in ${ES_PATH_CONF}/instances-http.yml --out ${ES_PATH_CONF}/certs/elasticsearch-http.zip;
         unzip -o ${ES_PATH_CONF}/certs/elasticsearch-http.zip -d ${ES_PATH_CONF}/certs; 

        # Adding CA to truststore
        if [[ ! -f ${ES_PATH_CONF}/certs/truststore.jks ]]; then
            # echo yes | /usr/share/elasticsearch/jdk/bin/keytool -import -v -trustcacerts -alias caelk -file ${ES_PATH_CONF}/certs/ca/ca.crt -keystore ${ES_PATH_CONF}/certs/truststore.jks -storepass 'changeit'
            truststore_status=$(echo yes | /usr/share/elasticsearch/jdk/bin/keytool -import -v -trustcacerts -alias caelk -file ${ES_PATH_CONF}/certs/ca/ca.crt -keystore ${ES_PATH_CONF}/certs/truststore.jks -storepass 'changeit' | grep keystore | cut -d" " -f4)
            if [[ $truststore_status -eq 1 ]]; then
                logger "INFO" "CA was successfully added to truststore."
            else
                logger "ERROR" "CA wasn't added to truststore."
            fi
        else
            # Check CA already present in truststore
            truststore_ca_present=$(/usr/share/elasticsearch/jdk/bin/keytool -list -keystore ${ES_PATH_CONF}/certs/truststore.jks -storepass 'changeit' | grep keystore | cut -d" " -f4)
            if [[ $truststore_ca_present -eq 1 ]]; then
                logger "INFO" "CA is already exist in truststore, skipping creation step..."
            else
                logger "ERROR" "CA wasn't found in truststore."
            fi
        fi

    else
        logger "ERROR" "Certificates wasn't generated."
    fi

else
    logger "INFO" "Certificates are already exists, skipping creation step."
fi

chown -R 1000:1000 $CERTS_DIR;
chmod -R 770 $CERTS_DIR;
# chown -R 1000:1000 /usr/share/elasticsearch/data;

logger "INFO" "$CONTAINER_NAME: Job done!"
