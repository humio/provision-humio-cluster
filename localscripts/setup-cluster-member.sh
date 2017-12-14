#!/bin/bash
set -e
set -x

DIR=`dirname $0`
cd $DIR

source config.conf
: "${USER:?Specify the USER running humio in config.conf}"

IP=$1
CPUS=`lscpu | grep 'NUMA node(s):' | cut -d':' -f2 | tr -d '[:space:]'`

python setup-cluster-member.py $IP $CPUS

sudo cp output/humio-config*.env output/*.properties output/nginx.conf /home/$USER/
sudo chown -R "$USER" /home/$USER/
sudo cp output/zookeeper-myid /data/zookeeper-data/myid
sudo chown -R "$USER" /data/zookeeper-data
