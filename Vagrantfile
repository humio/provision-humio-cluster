# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  (1..3).each do |i|
    config.vm.define "humio#{i}" do |humio|
      humio.vm.box = "debian/jessie64"

      humio.vm.network "private_network", ip: "10.0.0.#{i+1}"

      humio.vm.synced_folder ".", "/vagrant", type: "nfs"

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

  config.vm.provision "shell" do |s|
    #Add public key to support standard ssh with your user
    ssh_pub_key = File.readlines("#{Dir.home}/.ssh/id_rsa.pub").first.strip
    s.inline = <<-SHELL
      echo #{ssh_pub_key} >> /home/vagrant/.ssh/authorized_keys
      apt-get install -y rsync
    SHELL
  end
end
