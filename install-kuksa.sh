#!/usr/bin/env bash


# Windows Installation

#Install k3s
echo "Install a specific version of K3s? (y/n)"

read useVersion

if [[ $useVersion == 'y'  ]] then
  echo "Which version do you want to install?"
  read version
else 
  sudo curl -sfL https://get.k3s.io | sh -
fi

