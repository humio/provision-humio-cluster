#!/bin/bash
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
