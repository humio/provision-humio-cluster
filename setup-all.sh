#!/bin/bash
set -e
set -x

DIR=`dirname $0`
cd $DIR

source config.conf

echo provisioning
./provision.sh
echo setting up cluster member
./setup-cluster-member.sh
echo updating Docker containers
./update.sh

if [ "$NGINX" = "true" ]; then
    ./nginx-start.sh
fi

sleep 20
./configure-running-humio.sh
