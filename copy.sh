#!/bin/bash
set -e
set -x

: "${HOSTNAME:?Specify the hostname using env param HOSTNAME}"
: "${SSH_CONNECT:?Specify the  ssh username@host using env param SSH_CONNECT}"

ssh $SSH_CONNECT 'mkdir -p setup-humio'
rsync -avz files/ $SSH_CONNECT:setup-humio/
scp config.conf $SSH_CONNECT:setup-humio/
