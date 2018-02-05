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

CPUS=`lscpu | grep 'NUMA node(s):' | cut -d':' -f2 | tr -d '[:space:]'`
echo "Running $CPUS humio instances"

docker pull humio/humio-kafka
docker stop humio-kafka --time 30 || true
docker ps
#sleep 10 #otherwise we have experienced the next command fails with driver "aufs" failed to remove root filesystem
docker rm humio-kafka  -f || true

docker run -d --user `id -u $USER`  --restart always --net=host \
  --ulimit nofile=250000:250000 \
  -v /home/$USER/zookeeper.properties:/etc/kafka/zookeeper.properties \
  -v /home/$USER/kafka.properties:/etc/kafka/kafka.properties \
  -v /data/logs:/data/logs \
  -v /data/zookeeper-data:/data/zookeeper-data  \
  -v /data/kafka-data:/data/kafka-data  \
  --name humio-kafka "humio/humio-kafka"


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
    -v "/data/logs/humio${index}":/data/logs \
    -v "/data/humio-data${index}":/data/humio-data \
    --env-file "/home/${USER}/humio-config${index}.env" --name "$containerName" $HUMIO_IMAGE

  ((index++))
done
