# -*- mode: ruby -*-
# vi: set ft=ruby :
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.define :web do |web_config|
    web_config.vm.box = "ubuntu/precise64"
    web_config.vm.host_name = "web"
    web_config.vm.synced_folder ".", "/vagrant"

    web_config.vm.network "private_network", ip: "33.33.33.33"
    web_config.vm.provision "shell", path: "install.sh"

    ## nginx
    #web_config.vm.network "forwarded_port", guest: 80, host: 8080

    web_config.vm.provider "virtualbox" do |v|
      v.memory = 256
    end
  end
end
