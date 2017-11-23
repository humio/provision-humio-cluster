#!/bin/bash
set -e
set -x

DIR=`dirname $0`
cd $DIR

source ./setup.sh

: "${USER:?Specify a USER in config.conf. This is the user running on the host machines that will be running Humio}"

index=0
while [ $index -lt  ${#ssh_connects[@]} ]
do
  ssh -t "${ssh_connects[index]}" "sudo su -c ./setup-humio/nginx-start.sh $USER"
  ((index++))
done
