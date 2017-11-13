#!/bin/bash
set -e
set -x

DIR=`dirname $0`
cd $DIR

source ./setup.sh
ssh "${ssh_connects[0]}" "setup-humio/configure-humio.sh ${ips[0]}"
