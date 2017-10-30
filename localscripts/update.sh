#!/bin/bash
set -e
set -x

DIR=`dirname $0`
cd $DIR

source config.conf
: "${USER:?Specify the USER running humio in config.conf}"

if [ ! -d "/home/$USER/.docker" ]; then
      docker login
fi

echo "running shell as `whoami`"
echo "starting docker containers with user $USER"

docker pull humio/humio-kafka
docker stop humio-kafka || true
docker rm humio-kafka || true

docker run -d --user `id -u $USER`  --restart always --net=host \
  -v /home/$USER/zookeeper.properties:/etc/kafka/zookeeper.properties \
  -v /home/$USER/kafka.properties:/etc/kafka/kafka.properties \
  -v /data/logs:/data/logs \
  -v /data/zookeeper-data:/data/zookeeper-data  \
  -v /data/kafka-data:/data/kafka-data  \
  --name humio-kafka "humio/humio-kafka"

docker pull humio/humio-core
docker stop humio-core || true
docker rm humio-core || true

docker run -d --user `id -u $USER` --restart always --net=host \
  -v /data/logs:/data/logs \
  -v /data/humio-data:/data/humio-data \
  --env-file /home/$USER/humio-config.env --name humio-core humio/humio-core
