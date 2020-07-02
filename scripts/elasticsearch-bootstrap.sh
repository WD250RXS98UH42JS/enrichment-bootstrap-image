#!/usr/bin/env sh

source /scripts/logger.sh

# Simple script to load elasticsearch templates, ilm, policies, and all other required objects into the healthy cluster.

. "/scripts/check-service-availability.sh"

#Load in Index Lifecycle polices
logger "INFO" "Loading! -- ElasticSearch ILM Policies"
for f in /usr/share/elasticsearch/data/ilm-policies/*.json
do	
  logger "INFO" "Processing index lifecycle policy file (full path) $f."
  fn=$(basename $f)
  n="${fn%.*}"

  logger "INFO" "Processing file name $n."

  declare ilm_policies_response=$(curl -s -o /dev/null -w "%{http_code}" \
                                       -X PUT "$CHECK_SERVICE_URL:$CHECK_SERVICE_PORT/_ilm/policy/$n?pretty" \
                                       -H 'Content-Type: application/json' -d"@$f" \
                                       --key $CERTS_DIR/$CHECK_SERVICE_CERT/$CHECK_SERVICE_CERT.key \
                                       --cert $CERTS_DIR/$CHECK_SERVICE_CERT/$CHECK_SERVICE_CERT.crt \
                                       --cacert $CERTS_DIR/ca/ca.crt \
                                       -u $CHECK_SERVICE_USER:$CHECK_SERVICE_PASSWORD)

  [ $ilm_policies_response -eq 200 ] && logger "INFO" "$fn: processed successfully." || logger "ERROR" "$fn: processing failed."

done

#Load in Index Templates This includes mappings, settings, etc.
logger "INFO" "Loading! -- ElasticSearch Index Templates"
for f in /usr/share/elasticsearch/data/index-templates/*.json
do	
  logger "INFO" "Processing index template file (full path) $f "
  fn=$(basename $f)
  n="${fn%.*}"

  logger "INFO" "Processing file name $n "

  declare index_templates_response=$(curl -s -o /dev/null -w "%{http_code}" \
                                          -X PUT "$CHECK_SERVICE_URL:$CHECK_SERVICE_PORT/_template/$n?pretty" \
                                          -H 'Content-Type: application/json' -d"@$f" \
                                          --key $CERTS_DIR/$CHECK_SERVICE_CERT/$CHECK_SERVICE_CERT.key \
                                          --cert $CERTS_DIR/$CHECK_SERVICE_CERT/$CHECK_SERVICE_CERT.crt \
                                          --cacert $CERTS_DIR/ca/ca.crt \
                                          -u $CHECK_SERVICE_USER:$CHECK_SERVICE_PASSWORD)

  [ $index_templates_response -eq 200 ] && logger "INFO" "$fn: processed successfully." || logger "ERROR" "$fn: processing failed."

done

#Bootstrap all required indexes
logger "INFO" "Loading! -- Bootstraping Indexes"
for f in /usr/share/elasticsearch/data/index-bootstraps/*.json
do	
  logger "INFO" "Processing index bootstrap file (full path) $f "
  fn=$(basename $f)
  n="${fn%.*}"

  logger "INFO" "Processing file name $n "

  declare index_bootstraps_response=$(curl -s -o /dev/null -w "%{http_code}" \
                                           -X PUT "$CHECK_SERVICE_URL:$CHECK_SERVICE_PORT/$n-000001?pretty" \
                                           -H 'Content-Type: application/json' -d"@$f" \
                                           --key $CERTS_DIR/$CHECK_SERVICE_CERT/$CHECK_SERVICE_CERT.key \
                                           --cert $CERTS_DIR/$CHECK_SERVICE_CERT/$CHECK_SERVICE_CERT.crt \
                                           --cacert $CERTS_DIR/ca/ca.crt \
                                           -u $CHECK_SERVICE_USER:$CHECK_SERVICE_PASSWORD)

  [ $index_bootstraps_response -eq 200 ] && logger "INFO" "$fn: processed successfully." || logger "ERROR" "$fn: processing failed."

done

logger "INFO" "$CONTAINER_NAME: Job done!"