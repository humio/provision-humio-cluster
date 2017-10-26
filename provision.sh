#!/bin/bash
set -e
set -x

: "${SSH_CONNECT:?Specify the  ssh username@host using env param SSH_CONNECT}"

DIR=`dirname $0`
cd $DIR

./copy.sh
ssh $SSH_CONNECT 'sudo setup-humio/bootstrap-machine.sh'
