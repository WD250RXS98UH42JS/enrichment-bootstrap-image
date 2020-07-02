#!/usr/bin/env sh

source /scripts/logger.sh

# export ES_BIN_PATH=/usr/share/elasticsearch/bin


# create_user()
# {
#     local target_service=$1
#     local username=$2
#     local password=$3
#     local username_status=$(curl -s -o /dev/null -w "%{http_code}" \
#                             -XPUT -H 'Content-Type: application/json' \
#                             "$CHECK_SERVICE_URL:$CHECK_SERVICE_PORT/_security/user/$username" \
#                             -d '{"username":"'"$username"'","roles":[],"password":"'"$password"'":}')
#     if [ $username_status -eq 200 ]; then 
#         logger "INFO" "$target_service: User successfully created."
#         return 0
#     else
#         logger "ERROR" "$target_service: User wasn't created, something went wrong."
#         return 1
#     fi
# }

# check_user_exist()
# {
#     local username=$1
#     local username_status=$(curl -s -o /dev/null -w "%{http_code}" \
#                             "$CHECK_SERVICE_URL:$CHECK_SERVICE_PORT/_security/user/$username")
#     if [ $username_status -eq 200 ]; then 
#         logger "INFO" "Username already exists."
#         return 0
#     else
#         logger "INFO" "Username not exist, start to create user..."
#         return 1
#     fi
# }

# bootstrap_roles()
# {

# }

# change_password()
# {
#     local target_service=$1
#     local username=$2
#     local password=$3
#     local service_url=$CHECK_SERVICE_URL
#     local service_port=$CHECK_SERVICE_PORT

#     case $username in
#         elastic|logstash_system|kibana) 
#             logger "INFO" "Default username provided, skipping user creation..."
#             local username_status=200
#             ;;
#         *)
#             # Create custom username
#             local username_status="$(curl -s -o /dev/null -w "%{http_code}" \
#                                     -XPUT -H 'Content-Type: application/json' \
#                                     "$service_url:$service_port/_security/user/$username" \
#                                     -d '{"username":"'"$username"'","roles":[],"password":"'"$password"'"}')"
#             [ $username_status -eq 200 ] && logger "INFO" "$target_service: User created successfully." || logger "ERROR" "$target_service: User creation failed."
#             ;;
#     esac

#     if [ $username_status -eq 200 ]; then
#         local response="$(curl -s -o /dev/null -w "%{http_code}" \
#                         -XPUT -H 'Content-Type: application/json' \
#                         "$service_url:$service_port/_security/user/$username/_password" \
#                         -d '{ "password":"'"$password"'" }')"
#     else
#         local response=500
#     fi

#     [ $response -eq 200 ] && logger "INFO" "$target_service: password changed successfully." || logger "ERROR" "$target_service: password changing failed."
# }

# user_management()
# {
#     local target_service=$1
#     local username=$2
#     local password=$3
#     local service_url=$CHECK_SERVICE_URL
#     local service_port=$CHECK_SERVICE_PORT

#     [[ $(check_user_exist $username) -eq 1 ]] && create_user $target_service $username $password
# }

# if [[ ! -f "${ES_PATH_CONF}/elasticsearch.keystore" ]]; then
#     # Create keystore
#     $ES_BIN_PATH/elasticsearch-keystore create;
#     [[ -f "${ES_PATH_CONF}/elasticsearch.keystore" ]] && logger "INFO" "Keystore created successfully." || logger "ERROR" "Keystore not exist and wasn't created."

#     # Starting Elasticsearch instance in detached mode
#     $ES_BIN_PATH/elasticsearch &

#     # Wait until Elasticsearch become available
#     . "/scripts/check-service-availability.sh"

#     # Changing Elasticsearch bootstrap user password
#     printf "$ELASTIC_PASSWORD" | $ES_BIN_PATH/elasticsearch-keystore add --stdin "bootstrap.password"

#     # Changing Elasticsearch user password
#     change_password "Elasticsearch" $ELASTIC_USER $ELASTIC_PASSWORD

#     # Changing Logstash user password
#     change_password "Logstash" $LOGSTASH_USER $LOGSTASH_PASSWORD

#     # Changing Kibana user password
#     change_password "Kibana" $KIBANA_USER $KIBANA_PASSWORD

#     # COULD BE NEEDED TO ENABLE USERS MANUALLY
#     # PUT /_security/user/<USERNAME>/_enable
# else
#     logger "INFO" "Passwords already configured, skipping configuration step."
# fi;

export ELASTIC_BOOTSTRAP_USER=$CHECK_SERVICE_USER
export ELASTIC_BOOTSTRAP_PASSWORD=$CHECK_SERVICE_PASSWORD

create_user()
{
    local username_status=$(curl -s -o /dev/null -w "%{http_code}" \
                            -u $ELASTIC_BOOTSTRAP_USER:$ELASTIC_BOOTSTRAP_PASSWORD \
                            -XPUT -H 'Content-Type: application/json' \
                            "$CHECK_SERVICE_URL:$CHECK_SERVICE_PORT/_security/user/$2" \
                            -d '{"username":"'"$2"'","roles":[],"password":"'"$3"'"}')

    [ $username_status -eq 200 ] && \
    (logger "INFO" "$1: User successfully created."; return 0) || \
    (logger "ERROR" "$1: User wasn't created, something went wrong."; return 1)
}

check_user_exist()
{
    local username_status=$(curl -s -o /dev/null -w "%{http_code}" \
                            -u $ELASTIC_BOOTSTRAP_USER:$ELASTIC_BOOTSTRAP_PASSWORD \
                            "$CHECK_SERVICE_URL:$CHECK_SERVICE_PORT/_security/user/$2")

    [ $username_status -eq 200 ] && \
    (logger "INFO" "$1: Username already exists."; return 0) || \
    (logger "INFO" "$1: Username not exist, start to create user..."; return 1)
}

change_password()
{
    local password_status=$(curl -s -o /dev/null -w "%{http_code}" \
                            -u $ELASTIC_BOOTSTRAP_USER:$ELASTIC_BOOTSTRAP_PASSWORD \
                            -XPUT -H 'Content-Type: application/json' \
                            "$CHECK_SERVICE_URL:$CHECK_SERVICE_PORT/_security/user/$2/_password" \
                            -d '{ "password":"'"$3"'" }')

    [ $password_status -eq 200 ] && \
    (logger "INFO" "$1: Password changed successfully."; return 0) || \
    (logger "INFO" "$1: Password changing failed."; return 1)
}

bootstrap_roles()
{
    local raw_roles_list=$3
    local roles_list="$(jq -scR '.[:-1] | split(",")' <<< $raw_roles_list)"

    local roles_status=$(curl -s -o /dev/null -w "%{http_code}" \
                        -u $ELASTIC_BOOTSTRAP_USER:$ELASTIC_BOOTSTRAP_PASSWORD \
                        -XPUT -H 'Content-Type: application/json' \
                        "$CHECK_SERVICE_URL:$CHECK_SERVICE_PORT/_security/user/$2/" \
                        -d '{"username":"'"$2"'","roles":'$roles_list'}')

    [ $roles_status -eq 200 ] && \
    (logger "INFO" "$1: Roles $roles_list bootstrapped successfully."; return 0) || \
    (logger "ERROR" "$1: Bootstrapping of $roles_list roles was failed."; return 1)
}

user_management()
{
    local target_service=$1
    local username=$2
    local password=$3
    local roles_list=$4

    check_user_exist $target_service $username || create_user $target_service $username $password;
    change_password $target_service $username $password && bootstrap_roles $target_service $username $roles_list
}

# if [[ ! -f "${ES_PATH_CONF}/elasticsearch.keystore" ]]; then
    # Create keystore
    # $ES_BIN_PATH/elasticsearch-keystore create;
    # [[ -f "${ES_PATH_CONF}/elasticsearch.keystore" ]] && logger "INFO" "Keystore created successfully." || logger "ERROR" "Keystore not exist and wasn't created."

    # # Starting Elasticsearch instance in detached mode
    # $ES_BIN_PATH/elasticsearch &

    # Wait until Elasticsearch become available
    . "/scripts/check-service-availability.sh"

    # # Changing Elasticsearch bootstrap user password
    # printf "$ELASTIC_PASSWORD" | $ES_BIN_PATH/elasticsearch-keystore add --stdin "bootstrap.password"

    # Elasticsearch user management
    user_management "Elasticsearch" $ELASTIC_USER $ELASTIC_PASSWORD $ELASTIC_ROLES

    # Logstash user management
    user_management "Logstash" $LOGSTASH_USER $LOGSTASH_PASSWORD $LOGSTASH_ROLES

    # Kibana user management
    user_management "Kibana" $KIBANA_USER $KIBANA_PASSWORD $KIBANA_ROLES
# else
#     logger "INFO" "Users already configured, skipping configuration step."
# fi;

logger "INFO" "$CONTAINER_NAME: Job done!"