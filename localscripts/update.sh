#!/bin/bash
set -e
set -x

if [ ! -d "/home/humio/.docker" ]; then
      docker login
fi

docker pull humio/humio-kafka
docker stop humio-kafka || true
docker rm humio-kafka || true

docker run -d  --restart always --net=host \
  -v /home/humio/zookeeper.properties:/etc/kafka/zookeeper.properties \
  -v /home/humio/kafka.properties:/etc/kafka/kafka.properties \
  -v /data/logs:/data/logs \
  -v /data/zookeeper-data:/data/zookeeper-data  \
  -v /data/kafka-data:/data/kafka-data  \
  --name humio-kafka "humio/humio-kafka"

docker pull humio/humio-core
docker stop humio-core || true
docker rm humio-core || true

docker run -d  --restart always --net=host \
  -v /data/logs:/data/logs \
  -v /data/humio-data:/data/humio-data \
  --env-file /home/humio/humio-config.env --name humio-core humio/humio-core
