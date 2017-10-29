#!/bin/bash
set -e
set -x

DIR=`dirname $0`
cd $DIR

source config.conf
: "${USER:?Specify the USER running humio in config.conf}"

IP=$1

python setup-cluster-member.py $IP

sudo cp output/humio-config.env output/*.properties /home/$USER/
sudo chown -R "$USER" /home/$USER/
sudo cp output/zookeeper-myid /data/zookeeper-data/myid
sudo chown -R "$USER" /data/zookeeper-data
