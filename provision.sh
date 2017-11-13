#!/bin/bash
set -e
set -x

DIR=`dirname $0`
cd $DIR

source ./setup.sh

index=0
while [ $index -lt  ${#ssh_connects[@]} ]
do
  ssh "${ssh_connects[index]}" 'sudo setup-humio/bootstrap-machine.sh'
  ((index++))
done
