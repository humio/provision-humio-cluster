#!/bin/bash
set -e
set -x

DIR=`dirname $0`
cd $DIR

IP=$1
source config.conf
if [[ -z "${CPUS}" ]]; then
  CPUS=1
fi

TOKEN=`cat /data/humio-data1/local-admin-token.txt`
echo "CLUSTER MEMBERS:"
curl -H "Authorization: Bearer $TOKEN" "http://${IP}:8080/api/v1/clusterconfig/members" | jq .
echo "SETTING DEFAULTS"
curl -XPOST -H "Authorization: Bearer $TOKEN" "http://${IP}:8080/api/v1/clusterconfig/partitions/setdefaults"
echo "LISTING SEGMENT PARTITIONS"
curl -H "Authorization: Bearer $TOKEN" "http://${IP}:8080/api/v1/clusterconfig/segments/partitions" | jq .
echo "LISTING INGEST PARTITIONS"
curl -H "Authorization: Bearer $TOKEN" "http://${IP}:8080/api/v1/clusterconfig/ingestpartitions" | jq .
