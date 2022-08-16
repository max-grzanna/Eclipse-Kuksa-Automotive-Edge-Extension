#!/usr/bin/env bash

set -o errexit
set -o nounset

sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
sudo swapoff -a

DIR="$(cd "$(dirname "$0")" && pwd)"
namespace="kuksa"
releaseName="kuksa-cloud"

# Github image registry authentication information
USERNAME=""
PAT=""

function installChart() {
  kubectl delete namespace "$namespace"
  kubectl create namespace "$namespace"
  helm install "$releaseName" --namespace "$namespace" kuksa-cloud/
}

# Install packages
sudo apt-get update
sudo apt-get -y install curl resolvconf vim ca-certificates gnupg lsb-release

# set google dns server in order to resolve hosts like https://app.getambassador.io
echo "nameserver 8.8.8.8" >>/etc/resolvconf/resolv.conf.d/head
echo "nameserver 8.8.4.4" >>/etc/resolvconf/resolv.conf.d/head
sudo systemctl restart resolvconf.service
sudo systemctl restart systemd-resolved.service

sudo systemctl start resolvconf.service
sudo systemctl enable resolvconf.service

# install docker
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

sudo apt-get update
sudo apt-get -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin

# install docker engine
curl -O https://download.docker.com/linux/debian/dists/bullseye/pool/stable/amd64/docker-ce_20.10.10~3-0~debian-bullseye_amd64.deb
sudo dpkg -i docker-ce_20.10.10~3-0~debian-bullseye_amd64.deb

# login for github image registry
echo $PAT | docker login ghcr.io -u $USERNAME --password-stdin

# installing k3s without traefik (we use emissary ingress instead)
curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="644" INSTALL_K3S_EXEC="--disable=traefik" sh -

# Installing Helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
rm get_helm.sh

# Cluster access
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

cd Eclipse-Kuksa-Automotive-Edge-Extension/kuksa.cloud/deployment/helm/
helm dep up kuksa-cloud/

# installing charts
kubectl create namespace "$namespace" &&
  kubectl apply -f https://app.getambassador.io/yaml/emissary/3.0.0/emissary-crds.yaml
kubectl wait --timeout=90s --for=condition=available deployment emissary-apiext -n emissary-system
helm install "$releaseName" --namespace "$namespace" kuksa-cloud/ &&
  kubectl -n kuksa wait --for condition=available --timeout=90s deploy -lapp.kubernetes.io/instance=emissary-ingress


EXIT_STATUS=$?
if [ $EXIT_STATUS -ne 0 ]; then
  echo -e '\x1b[93mRetrying to install the chart...\x1b[0m \n'
  installChart
  exit
fi
