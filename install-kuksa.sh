#!/usr/bin/env bash

set -o errexit
set -o nounset

DIR="$(cd "$(dirname "$0")" && pwd)"

#Install k3s
printf "Install a specific version of K3s? (Y/n) "
read -r useVersion
printf "Install Helm? (Y/n) "
read -r installHelm

if [[ $useVersion == 'Y' ]]; then
  # Could be removed, if kuksa-cloud is working properly with latest k8s versions
  # Default is 1.17.2 because of deprecated CRDs
  # 1.17.2 is the newest version compatible with kuksa-cloud at the moment
  printf 'Which version do you want to install? [\x1b[36mLeave blank for v1.17.2+k3s1\x1b[0m]: '
  read -r version

  if [[ -z "$version" ]]; then
    version="v1.17.2+k3s1"
  fi

  curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=$version K3S_KUBECONFIG_MODE="644" sh -
else
  curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="644" sh -
fi

# Cluster access
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

# set permissions
sudo chmod 644 /etc/rancher/k3s/k3s.yaml

# Installing Helm
if [[ $installHelm == 'Y' ]]; then
  curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
  chmod 700 get_helm.sh
  "$DIR"/get_helm.sh
  rm get_helm.sh
fi

# install helm dep
cd kuksa.cloud/deployment/helm/
helm dep up kuksa-cloud/

# install charts
printf 'Do you want a custom release name? [\x1b[36mLeave blank for "kuksa-cloud"\x1b[0m]: '
read -r releaseName

if [[ -z "$releaseName" ]]; then
  releaseName="kuksa-cloud"
fi

helm install "$releaseName" kuksa-cloud/

exit
