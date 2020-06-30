#!/usr/bin/env sh

source /scripts/logger.sh

export ES_BIN_PATH=/usr/share/elasticsearch/bin

change_password()
{
    local target_service=$1
    local username=$2
    local password=$3
    local service_url=$CHECK_SERVICE_URL
    local service_port=$CHECK_SERVICE_PORT

    case $username in
        elastic|logstash_system|kibana) 
            logger "INFO" "Default username provided, skipping user creation..."
            local username_status=200
            ;;
        *)
            # Create custom username
            local username_status="$(curl -s -o /dev/null -w "%{http_code}" \
                      -XPUT -H 'Content-Type: application/json' \
                      "$service_url:$service_port/_security/user/$username" \
                      -d '{"username":"'"$username"'","roles":[],"password":"'"$password"'":}')"
            [ $username_status -eq 200 ] && logger "INFO" "$target_service: User created successfully." || logger "ERROR" "$target_service: User creation failed."
            ;;
    esac

    if [ $username_status -eq 200 ]; then
        local response="$(curl -s -o /dev/null -w "%{http_code}" \
                        -XPUT -H 'Content-Type: application/json' \
                        "$service_url:$service_port/_security/user/$username/_password" \
                        -d '{ "password":"'"$password"'" }')"
    else
        local $response=500
    fi

    [ $response -eq 200 ] && logger "INFO" "$target_service: password changed successfully." || logger "ERROR" "$target_service: password changing failed."
}

if [[ ! -f "${ES_PATH_CONF}/elasticsearch.keystore" ]]; then
    # Create keystore
    $ES_BIN_PATH/elasticsearch-keystore create;
    [[ -f "${ES_PATH_CONF}/elasticsearch.keystore" ]] && logger "INFO" "Keystore created successfully." || logger "ERROR" "Keystore not exist and wasn't created."

    # Starting Elasticsearch instance in detached mode
    $ES_BIN_PATH/elasticsearch &

    # Wait until Elasticsearch become available
    . "/scripts/check-service-availability.sh"

    # Changing Elasticsearch bootstrap user password
    printf "$ELASTIC_PASSWORD" | $ES_BIN_PATH/elasticsearch-keystore add --stdin "bootstrap.password"

    # Changing Elasticsearch user password
    change_password "Elasticsearch" $ELASTIC_USER $ELASTIC_PASSWORD

    # Changing Logstash user password
    change_password "Logstash" $LOGSTASH_USER $LOGSTASH_PASSWORD

    # Changing Kibana user password
    change_password "Kibana" $KIBANA_USER $KIBANA_PASSWORD

    # COULD BE NEEDED TO ENABLE USERS MANUALLY
    # PUT /_security/user/<USERNAME>/_enable
else
    logger "INFO" "Passwords already configured, skipping configuration step."
fi;

logger "INFO" "$CONTAINER_NAME: Job done!"