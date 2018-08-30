#!/bin/bash
set -e
set -x

DIR=`dirname $0`
cd $DIR

source config.conf
: "${USER:?Specify the USER running humio in config.conf}"

if [ -f "bootstrap-machine-specific.sh" ]; then
  ./bootstrap-machine-specific.sh
fi

apt-get update
apt-get install -y python jq curl
apt-get clean

if [ ! -d "/home/$USER" ]; then
    adduser --home "/home/$USER" --gecos "$USER" --disabled-password --disabled-login --shell /bin/bash "$USER"
fi

# install docker
if ! [ -x "$(command -v docker)" ]; then
  curl -fsSL https://get.docker.com/ | sh  ##this could be dangerous
  # add humio user to docker group
  usermod -aG docker $USER
  service docker restart
fi

# create humio directories
mkdir -p /data/logs/kafka
mkdir -p /data/logs/zk
mkdir -p /data/zookeeper-data
mkdir -p /data/kafka-data

CPUS=`lscpu | grep 'NUMA node(s):' | cut -d':' -f2 | tr -d '[:space:]'`
index=1
while [ $index -le $CPUS ]
do
  mkdir -p "/data/humio-data${index}"
  mkdir -p "/data/logs/humio${index}"
  ((++index))
done

chown -R $USER /data/*
