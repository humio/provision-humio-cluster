#!/bin/bash
set -e
set -x

sudo docker login
sudo docker pull humio/humio-kafka

sudo docker stop humio-kafka || true
sudo docker rm humio-kafka || true

sudo -u humio /bin/sh - << EOF
docker run -d  --restart always --net=host \
-v /home/humio/zookeeper.properties:/etc/kafka/zookeeper.properties \
-v /home/humio/kafka.properties:/etc/kafka/kafka.properties \
-v /data/logs:/data/logs \
-v /data/zookeeper-data:/data/zookeeper-data  \
-v /data/kafka-data:/data/kafka-data  \
--name humio-kafka "humio/humio-kafka"
EOF
