
# Experimental ansible provisioning and management scripts

To try this:

1. Install ansible (brew install ansible, apt install
   ansible)This has been tested with ansible version 2.5.2
1. Create test instance on AWS
1. ssh to test instance
1. Add ip of instance to inventory file: `hosts`
1. `ansible-playbook -i hosts bootstrap-ansible.yml` will
   make all hosts ready for ansible
1. `ansible-playbook -i hosts docker.yml` install docker on
   all hosts
1. `ansible-playbook -i hosts humio-zookeeper.yml -e
   run_mode=setup` install zookeeper on humio-zookeeper
   hosts.

Notice that the humio-zookeeper playbook in parameterized
with a run-mode. The following run-modes are available:
`setup`, `status`, `restart`, and `stop`. The run-modes are
a way to have both provisioning and management operations.

