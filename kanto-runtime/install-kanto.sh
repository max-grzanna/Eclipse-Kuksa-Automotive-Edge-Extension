#!/bin/bash

echo "Provisioning..."
sudo apt-get update

echo "INSTALL CURL"
sudo apt-get -y install curl

echo "GET CONTAINERD DEBIAN PACKAGES"
curl -fsSL https://github.com/eclipse-kanto/kanto/raw/main/quickstart/install_ctrd.sh | sh

echo "INSTALL ECLIPSE KANTO"
wget https://github.com/eclipse-kanto/kanto/releases/download/v0.1.0-M1/kanto_0.1.0-M1_linux_x86_64.deb && \
sudo apt-get -y install ./kanto_0.1.0-M1_linux_x86_64.deb

echo "VERIFY IF ALL SERVICES ARE RUNNING"
systemctl status \
suite-connector.service \
container-management.service \
software-update.service \
file-upload.service