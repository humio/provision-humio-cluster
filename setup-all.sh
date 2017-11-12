#!/bin/bash
set -e
set -x

DIR=`dirname $0`
cd $DIR

source ./config.conf
: "${SSH_CONNECTS:?Specify a SSH_CONNECTS string in config.conf with all the servers you need to connect to}"
: "${IPS:?Specify an IPS string in config.conf. This is the ip that each server will use as its bind address for humio}"

IFS=', ' read -r -a ssh_connects <<< "$SSH_CONNECTS"
IFS=', ' read -r -a ips <<< "$IPS"

if [ "${#ssh_connects[@]}" != "${#ips[@]}" ]; then
  echo "SSH_CONNECTS and IPS parameters must have the same number of hosts. SSH_CONNECTS=$SSH_CONNECTS IPS=$IPS"
  exit 1
fi

index=0
while [ $index -lt  ${#ssh_connects[@]} ]
do
  SSH_CONNECT="${ssh_connects[index]}" ./provision.sh
  SSH_CONNECT="${ssh_connects[index]}" IP=${ips[index]} ./setup-cluster-member.sh
  SSH_CONNECT="${ssh_connects[index]}" ./update.sh
  ((index++))
done

sleep 10
SSH_CONNECT="${ssh_connects[0]}" ./scripts/copy.sh
ssh "${ssh_connects[0]}" "setup-humio/configure-humio.sh ${ips[0]}"
