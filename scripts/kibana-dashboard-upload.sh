#!/usr/bin/env sh

source /scripts/logger.sh

until $(curl -u ${KIBANA_USER}:${KIBANA_PASSWORD} --output /dev/null --silent --fail http://kibana:5601/api/status);
do
logger "INFO" "Kibana is down, waits until it starts"
sleep 1
done

cd /scripts/dashboards
for file in $(ls /scripts/dashboards);
do
    curl -u ${KIBANA_USER}:${KIBANA_PASSWORD} -X POST "http://kibana:5601/api/saved_objects/_import"  -H "kbn-xsrf: true" --form file="@$file"
    logger "INFO" "$file succesfully uploaded"
done

logger "INFO" "$CONTAINER_NAME: Job done!"
