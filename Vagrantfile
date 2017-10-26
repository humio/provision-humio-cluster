# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  (1..3).each do |i|
    config.vm.define "humio#{i}" do |humio|
      humio.vm.box = "debian/jessie64"

      humio.vm.network "private_network", ip: "10.0.0.#{i+1}"

      humio.vm.synced_folder ".", "/vagran", type: "nfs"

      humio.vm.provider "virtualbox" do |vb|
        # Display the VirtualBox GUI when booting the machine
        vb.gui = false

        # Customize the amount of memory on the VM:
        vb.memory = "2048"
      end
    end
  end


  # View the documentation for the provider you are using for more
  # information on available options.

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.

  #config.vm.provision "shell", path: "bootstrap-machine.sh"

  config.vm.provision "shell", inline: <<-SHELL
     SSHKEY="ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAw2No8R9/j3JfZDLASjlqJoPV108yKlwmEGuAkAYTFXGiV0jQm5moNIjIVQIojER0QGLjFo2q3RbzOoRStGsR0AJIdEo/6P/cM1v0oBx1c7A82FfMOvsxR60jX2g3G3oDmpuZ/h+JZE6mAyfXLvvgHFLhB1AKL2e2DIxsRU0KsDPtKh7BnR7JvmyN2pUaQ/DoMtnhMGDz2WUOkipfZHL+9ikDJdkeyHtr7YGUwCK96fQxEqJtMdHRt2xZI/qnLcOqlpYixeEbd0Vw2pLN0R3n4RHpkbGqg1XBPBIphNE6sDwaEBdCDli6E+3Ar0Yq2le6na3T/nJYPmEdWro39ifklw== chvitved@gmail.com"
     echo "$SSHKEY" >> /home/vagrant/.ssh/authorized_keys
   SHELL
end
