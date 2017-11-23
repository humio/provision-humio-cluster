#!/bin/bash
set -e
set -x

DIR=`dirname $0`
cd $DIR

docker stop nginx-proxy || true
docker rm nginx-proxy || true

docker run \
 -d --restart=always --net=host \
 -v "/home/$USER/nginx.conf:/etc/nginx/nginx.conf:ro" \
 --name nginx-proxy nginx
