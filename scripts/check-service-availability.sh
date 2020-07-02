#!/usr/bin/env sh

source /scripts/logger.sh

service_status="red"

while [ "$service_status" != "$DESIRED_STATUS" ]
do
  logger "INFO" "Service isn't ready yet, retry..."
  sleep 3
  scheme=$(printf "$CHECK_SERVICE_URL" | cut -d ':' -f1)
  if [ "$scheme" == "http" ]; then
    # Checking through insecured connection
    service_health=$(curl -s -u $CHECK_SERVICE_USER:$CHECK_SERVICE_PASSWORD \
                    $CHECK_SERVICE_URL:$CHECK_SERVICE_PORT/_cluster/health)
    service_status=$(expr "$service_health" : '.*"status":"\([^"]*\)"')
  elif [ "$scheme" == "https" ]; then
    # Checking through secured connection
    service_health=$(curl -s -u $CHECK_SERVICE_USER:$CHECK_SERVICE_PASSWORD \
                            --key $CERTS_DIR/$CHECK_SERVICE_CERT/$CHECK_SERVICE_CERT.key \
                            --cert $CERTS_DIR/$CHECK_SERVICE_CERT/$CHECK_SERVICE_CERT.crt \
                            --cacert $CERTS_DIR/ca/ca.crt \
                            $CHECK_SERVICE_URL:$CHECK_SERVICE_PORT/_cluster/health)
    service_status=$(expr "$service_health" : '.*"status":"\([^"]*\)"')
  else
    logger "ERROR" "Error getting URL scheme - is it configured properly?"
  fi
done

logger "INFO" "Service became ready."
