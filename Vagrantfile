# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.box = "peru/ubuntu-20.04-desktop-amd64"
  config.vm.box_version = "20200601.01"
  config.vm.box_check_update = false
  #config.vm.network "public_network"
  config.ssh.forward_agent = true

  config.vm.provider "virtualbox" do |v|
    v.gui = true
    v.memory = 4096
    v.cpus = 2
    v.customize ["modifyvm", :id, "--cpuexecutioncap", "100", "--vram", "128"]
  end

  config.vm.synced_folder ".", "/vagrant", type: "virtualbox", automount: true, rsync__exclude: ".git/"
  config.vm.provision :shell, privileged: false, path: "p10_bootstrap.sh"

end
