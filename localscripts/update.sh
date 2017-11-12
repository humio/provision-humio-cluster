#!/bin/bash
set -e
set -x

DIR=`dirname $0`
cd $DIR

source config.conf
: "${USER:?Specify the USER running humio in config.conf}"

if [[ -z "${CPUS}" ]]; then
  CPUS=1
fi

if [ ! -d "/home/$USER/.docker" ]; then
      docker login
fi

echo "running shell as `whoami`"
echo "starting docker containers with user $USER"

docker pull humio/humio-kafka
docker stop humio-kafka --time 30 || true
docker ps
#sleep 10 #otherwise we have experienced the next command fails with driver "aufs" failed to remove root filesystem
docker rm humio-kafka  -f || true

docker run -d --user `id -u $USER`  --restart always --net=host \
  -v /home/$USER/zookeeper.properties:/etc/kafka/zookeeper.properties \
  -v /home/$USER/kafka.properties:/etc/kafka/kafka.properties \
  -v /data/logs:/data/logs \
  -v /data/zookeeper-data:/data/zookeeper-data  \
  -v /data/kafka-data:/data/kafka-data  \
  --name humio-kafka "humio/humio-kafka"


docker pull humio/humio-core

index=1
while [ $index -le $CPUS ]
do
  cores=`cat /proc/cpuinfo|egrep "processor" | cut -d':' -f 2 | cut -d ' ' -f 2 | wc -l`
  cpuset=`python divide-cpus.py $CPUS $cores $index`
  cpusetStr="--cpuset-cpus=$cpuset"

  containerName="humio-core${index}"

  docker stop $containerName --time 30 || true
  docker rm $containerName || true

  docker run -d --user `id -u $USER` --restart always --net=host \
    $cpusetStr \
    -v "/data/logs/humio${index}":/data/logs \
    -v "/data/humio-data${index}":/data/humio-data \
    --env-file "/home/${USER}/humio-config${index}.env" --name "$containerName" humio/humio-core

  ((index++))
done
