#!/bin/bash
set -e
set -x

: "${IP:?Specify the ip-address using env param IP}"
: "${SSH_CONNECT:?Specify the  ssh username@host using env param SSH_CONNECT}"

DIR=`dirname $0`
cd $DIR

./scripts/copy.sh
ssh $SSH_CONNECT "setup-humio/setup-cluster-member.sh $IP"
