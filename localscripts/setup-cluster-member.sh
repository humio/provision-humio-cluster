#!/bin/bash
set -e
set -x

DIR=`dirname $0`
cd $DIR

HOSTNAME=$1

python setup-cluster-member.py $HOSTNAME

sudo cp output/humio-config.env output/*.properties /home/humio/
sudo chown -R humio /home/humio/
sudo cp output/zookeeper-myid /data/zookeeper-data/myid
sudo chown -R humio /data/zookeeper-data
#add hosts to /etc/hosts

LEAD='^### humio-section$'
TAIL='^### humio-section-end$'
sudo sed -i "/$LEAD/,/$TAIL/d" /etc/hosts
cat output/hosts | sudo tee -a /etc/hosts
