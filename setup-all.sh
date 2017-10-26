#!/bin/bash
set -e
set -x

DIR=`dirname $0`
cd $DIR

USER=vagrant
HUMIO_HOST_NAME=humio
SSH_CONNECT1=$USER@10.0.0.2
SSH_CONNECT2=$USER@10.0.0.3
SSH_CONNECT3=$USER@10.0.0.4

#SSH_CONNECT="$SSH_CONNECT1" ./provision.sh
#SSH_CONNECT="$SSH_CONNECT2" ./provision.sh
#SSH_CONNECT="$SSH_CONNECT3" ./provision.sh

#SSH_CONNECT="$SSH_CONNECT1" HOSTNAME="$HUMIO_HOST_NAME"1 ./setup-cluster-member.sh
#SSH_CONNECT="$SSH_CONNECT2" HOSTNAME="$HUMIO_HOST_NAME"2 ./setup-cluster-member.sh
#SSH_CONNECT="$SSH_CONNECT3" HOSTNAME="$HUMIO_HOST_NAME"3 ./setup-cluster-member.sh

SSH_CONNECT="$SSH_CONNECT1" ./update.sh
SSH_CONNECT="$SSH_CONNECT2" ./update.sh
SSH_CONNECT="$SSH_CONNECT3" ./update.sh

sleep 10
ssh "$SSH_CONNECT1" 'setup-humio/configure-humio.sh'
