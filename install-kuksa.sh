#!/usr/bin/env bash

set -o errexit
set -o nounset

DIR="$(cd "$(dirname "$0")" && pwd)"

printf "Install Helm? (Y/n) "
read -r installHelm

printf 'Do you want a custom release name? [\x1b[36mLeave blank for "kuksa-cloud"\x1b[0m]: '
read -r releaseName

if [[ -z "$releaseName" ]]; then
  releaseName="kuksa-cloud"
fi

printf 'Custom namespace for kuksa installation? [\x1b[36mLeave blank for "kuksa"\x1b[0m]: '
read -r namespace

if [[ -z "$namespace" ]]; then
  namespace="kuksa"
fi

# installing k3s without traefik (we use emissary ingress instead)
curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="644" INSTALL_K3S_EXEC="--disable=traefik" sh -

# Cluster access
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

# Installing Helm
if [[ $installHelm == 'Y' ]]; then
  curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
  chmod 700 get_helm.sh
  "$DIR"/get_helm.sh
  rm get_helm.sh
fi

cd kuksa.cloud/deployment/helm/
helm dep up kuksa-cloud/

# installing charts
kubectl create namespace "$namespace" &&
  kubectl apply -f https://app.getambassador.io/yaml/emissary/2.3.1/emissary-crds.yaml
kubectl wait --timeout=90s --for=condition=available deployment emissary-apiext -n emissary-system
helm install "$releaseName" --namespace "$namespace" kuksa-cloud/ &&
  kubectl -n kuksa wait --for condition=available --timeout=90s deploy -lapp.kubernetes.io/instance=emissary-ingress

if [ $? -eq 0 ]; then
  exit
else
  echo -e '\x1b[93mRetrying to install the chart...\x1b[0m \n'
  kubectl delete namespace "$namespace"
  kubectl create namespace "$namespace"
  helm install "$releaseName" --namespace "$namespace" kuksa-cloud/
fi
