#!/bin/bash

export DEFAULT_CONTAINER_TAG="test"
export DEFAULT_IMG_TAG=7es7/enrichment-bootstrap:latest

set_img_tag()
{
    [ "$1" = "D" ] && export IMG_TAG=$DEFAULT_IMG_TAG || export IMG_TAG=$1
}

build() 
{
    docker build -t $IMG_TAG . && docker push $IMG_TAG
}

run()
{
    docker run -d -t \
    -e ES_PATH_CONF='/usr/share/elasticsearch/data/config' \
    -e CERTS_DIR='/tmp/certs' \
    -e SERVICE_URL='http://127.0.0.1' \
    -e SERVICE_PORT='9200' \
    -e DESIRED_STATUS='green' \
    -e network.host='127.0.0.1' \
    -e discovery.type='single-node' \
    -e xpack.license.self_generated.type='trial' \
    -e xpack.security.enabled='true' \
    -e xpack.security.authc.anonymous.username='anonymous_user' \
    -e xpack.security.authc.anonymous.roles='superuser' \
    -e ELASTIC_USER_B64='ZWxhc3RpYwo=' \
    -e ELASTIC_PASSWORD_B64='cGFzc3dvcmQ=' \
    -e LOGSTASH_USER_B64='bG9nc3Rhc2hfc3lzdGVtCg==' \
    -e LOGSTASH_PASSWORD_B64='cGFzc3dvcmQ=' \
    -e KIBANA_USER_B64='a2liYW5hCg==' \
    -e KIBANA_PASSWORD_B64='cGFzc3dvcmQ=' \
    --name $DEFAULT_CONTAINER_TAG $IMG_TAG
}

get_container()
{
    export CONTAINER_ID=`docker ps --filter "ancestor=$IMG_TAG" -q`
}

copy_script()
{
    get_container && \
    docker cp $1 $CONTAINER_ID:$2
    status=$(docker exec -it $CONTAINER_ID /bin/bash -c "ls $2")
    [[ "$status" == "$2"* ]] && echo "success" || echo "fail"

}

execute()
{
    get_container && \
    docker exec -it $CONTAINER_ID $1
}

stop_container()
{
    get_container && \
    docker rm -f $CONTAINER_ID
}

set_img_tag $2
while getopts 'brcexsa' OPTION
do
  case ${OPTION} in
    b)
      build
      ;;
    r)
      run
      ;;
    c)
      copy_script $3 $4
      ;;
    e)
      execute $3
      ;;
    x)
      copy_script $3 $4 && execute $4
      ;;
    s)
      stop_container
      ;;
    a)
      stop_container 2> /dev/null;
      build && run && copy_script $3 $4 && execute $4
      ;;
    *)
      echo "Usage ${0} [ -b ] b = build, [ -r ] r = run, [ -c ] c = copy script, [ -a ] a = build and run"
      popd  > /dev/null 2>&1
      exit 1
      ;;
  esac
done