# Eclipse-Kuksa-Automotive-Edge-Extension

In order to use this demo application, you need to have Vagrant and VirtualBox installed.

## Setting up the development environment

The setup is divided into in-vehicle and cloud backend part. Both parts are running in separate virtual machines managed by Vagrant and VirtualBox.

To start the virtual machine use:
```bash
vagrant up
```
This will spin up both machine and provision them. 

If there are any problems with the containers not starting correctly inside the Kuksa.cloud machine:


```bash
kubectl -n kube-system edit configmaps coredns -o yaml
```
Modify the section` forward . /etc/resolv.conf` with `forward . 8.8.8.8`
