#!/bin/bash
set -e
set -x

cat << EOF | tee /etc/security/limits.d/99-humio-limits.conf
# Added by humio provisioning script: Raise limits for files.
* soft nofile 250000
* hard nofile 250000
humio soft nofile 250000
humio hard nofile 250000
root soft nofile 250000
root hard nofile 250000
EOF

grep 'session required pam_limits.so' /etc/pam.d/common-session > /dev/null || cat << EOF | tee -a /etc/pam.d/common-session
# Added by humio provisioning script:
session required pam_limits.so
EOF


export DEBIAN_FRONTEND=noninteractive
apt-get update
# Upgrade as much as possible.
apt-get -yq dist-upgrade
apt-get -yq autoremove
apt-get -yq install curl nano emacs-nox unattended-upgrades lsof jq smartmontools htop dstat

timedatectl  set-timezone UTC
service rsyslog restart

# Disable IPv6 for the time being.
cat << EOF | tee /etc/sysctl.d/99-humio-no-ipv6.conf
# Disable IPv6 for now....
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
# Allow larger backlog of connections:
net.core.somaxconn=4096
net.ipv4.tcp_max_syn_backlog=4096

EOF

sudo service procps reload
sysctl -p

if [ ! -d "/home/humio" ]; then
    adduser --home /home/humio --gecos 'Humio' --disabled-password --disabled-login --shell /bin/bash humio
fi

# install docker
if [ ! -f "/usr/bin/docker" ]; then
    curl -fsSL https://get.docker.com/ | sh  ##this could be dangerous
    # add humio user to docker group
    usermod -aG docker humio 
    service docker restart
fi

# create humio directories
mkdir -p /data/logs
chown -R humio:humio /data/logs
mkdir -p /data/zookeeper-data
chown -R humio:humio /data/zookeeper-data

apt-get clean
