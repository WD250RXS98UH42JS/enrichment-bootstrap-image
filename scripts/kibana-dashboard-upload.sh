#!/usr/bin/env sh

source /scripts/logger.sh

until $(curl --output /dev/null --silent --head --fail http://kibana:5601/status);
do
logger "INFO" "Kibana is down, waits until it starts"
sleep 1
done

for file in $(ls /scripts/dashboards);
do
    curl -X POST "http://kibana:5601/api/saved_objects/_import" --insecure  -H "kbn-xsrf: true" --form file="@$file"
    logger "INFO" "$file succesfully uploaded"
done

logger "INFO" "$CONTAINER_NAME: Job done!"
