#!/bin/bash
set -e
set -x

DIR=`dirname $0`
cd $DIR

source config.conf
: "${USER:?Specify the USER running humio in config.conf}"

if [ ! -d "bootstrap-machine-specific.sh" ]; then
  ./bootstrap-machine-specific.sh
fi

cat << EOF | tee /etc/security/limits.d/99-humio-limits.conf
# Added by humio provisioning script: Raise limits for files.
* soft nofile 250000
* hard nofile 250000
${USER} soft nofile 250000
${USER} hard nofile 250000
root soft nofile 250000
root hard nofile 250000
EOF

grep 'session required pam_limits.so' /etc/pam.d/common-session > /dev/null || cat << EOF | tee -a /etc/pam.d/common-session
# Added by humio provisioning script:
session required pam_limits.so
EOF


# Disable IPv6 for the time being.
cat << EOF | tee /etc/sysctl.d/99-humio.conf
net.core.somaxconn=4096
net.ipv4.tcp_max_syn_backlog=4096
EOF

sudo service procps reload
sysctl -p

if [ ! -d "/home/$USER" ]; then
    adduser --home "/home/$USER" --gecos "$USER" --disabled-password --disabled-login --shell /bin/bash "$USER"
fi

# install docker
if [ ! -f "/usr/bin/docker" ]; then
    curl -fsSL https://get.docker.com/ | sh  ##this could be dangerous
    # add humio user to docker group
    usermod -aG docker $USER
    service docker restart
fi

# create humio directories
mkdir -p /data/logs/kafka
mkdir -p /data/zookeeper-data
mkdir -p /data/kafka-data
mkdir -p /data/humio-data
chown -R $USER /data/*

apt-get clean
