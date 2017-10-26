#!/bin/bash
set -e
set -x

DIR=`dirname $0`
cd $DIR

SSH_CONNECT=vagrant@10.0.0.2 ./provision.sh
SSH_CONNECT=vagrant@10.0.0.3 ./provision.sh
SSH_CONNECT=vagrant@10.0.0.4 ./provision.sh

SSH_CONNECT=vagrant@10.0.0.2 HOSTNAME=humio1 ./setup-cluster-member.sh
SSH_CONNECT=vagrant@10.0.0.3 HOSTNAME=humio2 ./setup-cluster-member.sh
SSH_CONNECT=vagrant@10.0.0.4 HOSTNAME=humio3 ./setup-cluster-member.sh

SSH_CONNECT=vagrant@10.0.0.2 ./update.sh
SSH_CONNECT=vagrant@10.0.0.3 ./update.sh
SSH_CONNECT=vagrant@10.0.0.4 ./update.sh

sleep 10
ssh vagrant@10.0.0.3 << EOF
set -e
set -x
TOKEN=`cat /data/humio-data/local-admin-token.txt`
echo "CLUSTER MEMBERS:"
curl -H "Authorization: Bearer $TOKEN" "http://localhost:8080/api/v1/clusterconfig/members" | jq .
echo "SETTING DEFAULTS"
curl -XPOST -H "Authorization: Bearer $TOKEN" "http://localhost:8080/api/v1/clusterconfig/partitions/setdefaults"
echo "LISTING SEGMENT PARTITIONS"
curl -H "Authorization: Bearer $TOKEN" "http://localhost:8080/api/v1/clusterconfig/segments/partitions" | jq .
echo "LISTING INGEST PARTITIONS"
curl -H "Authorization: Bearer $TOKEN" "http://localhost:8080/api/v1/clusterconfig/ingestpartitions" | jq .

EOF
