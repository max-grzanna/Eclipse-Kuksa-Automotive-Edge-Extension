# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.define "kanto" do |kanto|
    kanto.vm.box = "bento/debian-11"
    kanto.vm.hostname = 'kanto'

    kanto.vm.network :private_network, ip: "192.168.56.50"

    kanto.vm.provider :virtualbox do |v|
      v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
            v.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
      v.memory = 2048
      v.cpus = 2
      v.customize ["modifyvm", :id, "--name", "kanto"]
      v.customize ["modifyvm", :id, "--ioapic", "on"]
    end

    kanto.vm.provision "shell", path: "install-kanto.sh"

  end

  config.vm.define "kuksa" do |kuksa|
    kuksa.vm.box = "bento/debian-11"
    kuksa.vm.hostname = "kuksa"

    kuksa.vm.network :private_network, ip: "192.168.56.51"

    kuksa.vm.provider :virtualbox do |v|
      v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      v.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
      v.memory = 4096
      v.cpus = 4
      v.customize ["modifyvm", :id, "--name", "kuksa"]
      v.customize ["modifyvm", :id, "--ioapic", "on"]
    end

    kuksa.vm.provision "file", source: ".", destination: "$HOME/Eclipse-Kuksa-Automotive-Edge-Extension"
    kuksa.vm.provision "shell", path: "install-kuksa-vagrant.sh"

  end
end
