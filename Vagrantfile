# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.define "kanto" do |kanto|
    kanto.vm.box = "debian/bullseye64"
    kanto.vm.hostname = 'kanto'

    kanto.vm.network :private_network, ip: "192.168.56.101"

    kanto.vm.provider :virtualbox do |v|
      v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      v.memory = 2048
      v.cpus = 2
      v.customize ["modifyvm", :id, "--name", "kanto"]
    end

    kanto.vm.provision "shell", path: "install-kanto.sh"

  end

  config.vm.define "kuksa" do |kuksa|
    kuksa.vm.box = "debian/bullseye64"
    kuksa.vm.hostname = 'kuksa'

    kuksa.vm.network :private_network, ip: "192.168.56.102"

    kuksa.vm.provider :virtualbox do |v|
      v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      v.memory = 2048
      v.cpus = 2
      v.customize ["modifyvm", :id, "--name", "kuksa"]
    end

    kuksa.vm.provision "shell", path: "install-kuksa-vagrant.sh"

  end
end