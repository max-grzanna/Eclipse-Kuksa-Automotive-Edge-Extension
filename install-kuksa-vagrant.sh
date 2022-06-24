#!/usr/bin/env bash

set -o errexit
set -o nounset

DIR="$(cd "$(dirname "$0")" && pwd)"
namespace="kuksa"
releaseName="kuksa-cloud"

function installChart() {
  kubectl delete namespace "$namespace"
  kubectl create namespace "$namespace"
  helm install "$releaseName" --namespace "$namespace" kuksa-cloud/
}

# Install packages
sudo apt-get update
sudo apt-get -y install curl git resolvconf

# set google dns server in order to resolve hosts like https://app.getambassador.io
echo "nameserver 8.8.8.8" >>/etc/resolvconf/resolv.conf.d/head
sudo systemctl restart resolvconf.service
sudo systemctl restart systemd-resolved.service

sudo systemctl start resolvconf.service
sudo systemctl enable resolvconf.service

# installing k3s without traefik (we use emissary ingress instead)
curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="644" INSTALL_K3S_EXEC="--disable=traefik" sh -

# Cluster access
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

# Installing Helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
rm get_helm.sh

git clone https://github.com/max-grzanna/Eclipse-Kuksa-Automotive-Edge-Extension.git Eclipse-Kuksa-Automotive-Edge-Extension

cd Eclipse-Kuksa-Automotive-Edge-Extension/kuksa.cloud/deployment/helm/
helm dep up kuksa-cloud/

export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

# installing charts
kubectl create namespace "$namespace" &&
  kubectl apply -f https://app.getambassador.io/yaml/emissary/2.3.1/emissary-crds.yaml
kubectl wait --timeout=90s --for=condition=available deployment emissary-apiext -n emissary-system
helm install "$releaseName" --namespace "$namespace" kuksa-cloud/ &&
  kubectl -n kuksa wait --for condition=available --timeout=90s deploy -lapp.kubernetes.io/instance=emissary-ingress


# TODO: Background job workaround (keeps failing for the first time executed)
EXIT_STATUS=$?
if [ $EXIT_STATUS -ne 0 ]; then
  echo -e '\x1b[93mRetrying to install the chart...\x1b[0m \n'
  installChart
fi
