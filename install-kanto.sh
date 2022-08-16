#!/usr/bin/env bash

sudo apt-get update

echo "Installing dependencies..."
sudo apt-get -y install curl python3-pip vim iptables

echo "GET CONTAINERD DEBIAN PACKAGES"
curl -fsSL https://github.com/eclipse-kanto/kanto/raw/main/quickstart/install_ctrd.sh | sh

echo "INSTALL ECLIPSE KANTO"
wget https://github.com/eclipse-kanto/kanto/releases/download/v0.1.0-M1/kanto_0.1.0-M1_linux_x86_64.deb &&
  sudo apt-get -y install ./kanto_0.1.0-M1_linux_x86_64.deb

# install docker
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

sudo apt-get update
sudo apt-get -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin

mkdir quickstart && cd quickstart &&
  wget https://github.com/eclipse-kanto/kanto/raw/main/quickstart/hono_commands.py &&
  wget https://github.com/eclipse-kanto/kanto/raw/main/quickstart/hono_events.py &&
  wget https://github.com/eclipse-kanto/kanto/raw/main/quickstart/requirements.txt &&
  wget https://github.com/eclipse-kanto/kanto/raw/main/quickstart/hono_provisioning.sh

pip3 install -r requirements.txt

# Create Directories where container will be running
cd ..
sudo mkdir kuksaval.config && sudo mkdir kuksa.gps.feeder.config && sudo mkdir kuksa.kanto.config && sudo mkdir kuksa.dbc.feeder.config

# Configure your local registry as an insecure one
sudo rm /etc/container-management/config.json
sudo cp config.json /etc/container-management/config.json

# spin up registry with all images
(
  cd docker-registry/ || exit; sudo docker compose up -d
)
# prevent cgroup error with kanto
sudo mkdir /sys/fs/cgroup/systemd && sudo mount -t cgroup -o none,name=systemd cgroup /sys/fs/cgroup/systemd


