#!/bin/bash

./run.sh -s D

./run.sh -r D

./run.sh -e D "/bin/bash -c 'mkdir -p /tmp/certs'"

./run.sh -x D /Users/kyryloyermak/Documents/dev/ping-cloud-base/k8s-configs/cluster-tools/logging/elastic-stack/enrichment/files/docker/scripts/create-ca.sh /scripts/create-ca.sh

# ./run.sh -c D /Users/kyryloyermak/Documents/dev/sandbox/test/instances.yml /usr/share/elasticsearch/config/instances.yml

# ./run.sh -c D /Users/kyryloyermak/Documents/dev/ping-cloud-base/k8s-configs/cluster-tools/logging/elastic-stack/enrichment/files/docker/scripts/move-elasticsearch-config.sh /scripts/move-elasticsearch-config.sh

# ./run.sh -x D /Users/kyryloyermak/Documents/dev/ping-cloud-base/k8s-configs/cluster-tools/logging/elastic-stack/enrichment/files/docker/scripts/create-certs.sh /scripts/create-certs.sh

# ./run.sh -x D /Users/kyryloyermak/Documents/dev/ping-cloud-base/k8s-configs/cluster-tools/logging/elastic-stack/enrichment/files/docker/scripts/create-passwords.sh /scripts/create-passwords.sh

# ./run.sh -e D "/bin/bash"

# curl -v -u elastic:password http://127.0.0.1:9200/_xpack/security/_authenticate?pretty