#!/bin/bash
set -e
set -x

DIR=`dirname $0`
cd $DIR

./provision.sh
./setup-cluster-member.sh
./update.sh

sleep 10
./configure-running-humio.sh
