#!/bin/bash
set -e
set -x

DIR=`dirname $0`
cd $DIR

source config.conf
: "${USER:?Specify the USER running humio in config.conf}"

echo "running shell as `whoami`"
echo "starting docker containers with user $USER"

CPUS=`lscpu | grep 'NUMA node(s):' | cut -d':' -f2 | tr -d '[:space:]'`
echo "Running $CPUS humio instances"

docker pull humio/zookeeper
docker stop humio-zookeeper --time 30 || true
docker ps
#sleep 30 #otherwise we have experienced the next command fails with driver "aufs" failed to remove root filesystem
docker rm -f humio-zookeeper || true

docker run -d --user `id -u $USER`  --restart always --net=host \
  --ulimit nofile=250000:250000 \
  -v /home/$USER/zookeeper.properties:/etc/kafka/zookeeper.properties \
  -v /data/logs/zk:/data/logs/kafka \
  -v /data/zookeeper-data:/data/zookeeper-data  \
  --name humio-zookeeper "humio/zookeeper"


docker pull humio/kafka
docker stop humio-kafka --time 30 || true
docker ps
#sleep 30 #otherwise we have experienced the next command fails with driver "aufs" failed to remove root filesystem
docker rm -f humio-kafka || true

docker run -d --user `id -u $USER`  --restart always --net=host \
    --ulimit nofile=250000:250000 \
    -v /home/$USER/kafka.properties:/etc/kafka/kafka.properties \
    -v /data/logs/kafka:/data/logs/kafka \
    -v /data/kafka-data:/data/kafka-data  \
    --name humio-kafka "humio/kafka"


HUMIO_IMAGE=humio/humio-core
docker pull $HUMIO_IMAGE

index=1
while [ $index -le $CPUS ]
do
  zeroBasedIndex=$((index-1))
  cpuSet=`lscpu | grep "NUMA node${zeroBasedIndex}" | cut -d':' -f2 | tr -d '[:space:]'`
  cpusetStr="--cpuset-cpus=$cpuSet"
  containerName="humio-core${index}"
  docker stop $containerName --time 30 || true
  docker rm $containerName || true

  docker run -d --user `id -u $USER` --restart always --net=host \
    --ulimit nofile=250000:250000 \
    $cpusetStr \
    -v /etc/humio:/etc/humio:ro \
    -v "/data/logs/humio${index}":/data/logs \
    -v "/data/humio-data${index}":/data/humio-data \
    --env-file "/home/${USER}/humio-config${index}.env" --name "$containerName" $HUMIO_IMAGE

  ((++index))
done
