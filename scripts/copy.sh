#!/bin/bash
set -e
set -x

: "${SSH_CONNECT:?Specify the  ssh username@host using env param SSH_CONNECT}"

ssh $SSH_CONNECT 'mkdir -p setup-humio && chmod +r setup-humio'
rsync -avz localscripts/ $SSH_CONNECT:setup-humio/
scp config.conf $SSH_CONNECT:setup-humio/
