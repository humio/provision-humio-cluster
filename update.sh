#!/bin/bash
set -e
set -x

source config.conf
: "${USER:?Specify the USER running humio in config.conf}"
: "${SSH_CONNECT:?Specify the  ssh username@host using env param SSH_CONNECT}"

DIR=`dirname $0`
cd $DIR

./scripts/copy.sh
ssh -t $SSH_CONNECT "sudo su -c ./setup-humio/update.sh $USER"
