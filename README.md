# Scripts for setting up Humio

This repository contains scripts to setup 1 machine or a cluster of Humio machines.

The scripts are written in Bash with a little bit of Python.  
Scripts are run from the local machine, but they will copy files to the target machines. Login using SSH and run local scripts.  
Before running the scripts, setup the machines with SSH public-key authentication, to avoid having to provide your password many times.

The recommended operating system for Humio is Ubuntu 16.04 which these scripts target.  
A few `apt` installs are used, but we try to keep the scripts compatible with Linux in general.

These scripts will do the following on the target machines (running as root):

* install Docker Python, jq, and curl
* Create a user running Humio
* Create a `/data` directory Humio will use
* Setup configuration files in the Humio users home dir
* Download and run Docker containers.

We encourage inspecting the scripts. Especially look at the `bootstrap-machine.sh` script that will provision the machine and install software.


It is important to note that **no security is setup**. Humio is run without authentication on port 8080. Kafka and Zookeeper are also running and listening on the configured ports.
Do not expose the machine on public networks until security is in place. Please contact us at Humio and we will be happy to help.

Humio is running as Docker containers, so no more software needs to be installed on the host machine.
A Humio installation consists of 2 containers:

  * Humio
  * Kafka/Zookeper

The Humio container is started in as many instances as the Host machine has CPUs (do not confuse with cores).

## Configuring
The project is configured using a file `config.conf`

The file can look like this:  
```
IPS=10.0.0.2,10.0.0.3,10.0.0.4
SSH_CONNECTS=ubuntu@10.0.0.2,ubuntu@10.0.0.3,ubuntu@10.0.0.4
USER=humio
```

### `IPS`
A comma delimited list of IP addresses. This will specify the IP address of each Humio server. The address specified here, is the address the server itself will use as bind address. It is also the IP address the other servers will use to contact this server. It is not necessary for the user running the provisioning to be able to connect on these addresses. The provisioning is done over SSH using the `SSH_CONNECTS` configuration.  

### `SSH_CONNECTS`
A comma delimited list of SSH connect strings, that will be used to login to the remote machines from the local machine running the provisioning.

### `USER`
The user that will be created on the Humio servers. This will be the user running Humio (and Kafka/Zookeeper)



## Run the scripts

Overall the project has 3 scripts:
* `provision.sh` - Will install software, setup a user and the necessary directories
* `setup-cluster-member.sh` - Will create the necessary configuration files in the Humio users home dir
* `update.sh` - Will fetch and run the necessary Docker containers. This script can also be used to update Humio to a new version

The script `setup-all.sh` will call all of the above scripts.

