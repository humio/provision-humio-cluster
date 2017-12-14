#!/bin/bash
set -e
set -x

DIR=`dirname $0`
cd $DIR

source config.conf

./provision.sh
./setup-cluster-member.sh
./update.sh

if [ "$NGINX" = "true" ]; then
    ./nginx-start.sh
fi

sleep 20
./configure-running-humio.sh
