#!/bin/bash

INTERFACE=eth1
SERVER_IP=192.168.56.111

SHARED_FOLDER=/home/vagrant/shared

echo "INSTALLING K3S"
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--node-ip=$SERVER_IP --flannel-iface=$INTERFACE --write-kubeconfig-mode=644" sh - 

echo "COPYINNG NODE TOKEN"
cp /var/lib/rancher/k3s/server/node-token $SHARED_FOLDER

echo "ALIAS K added"
echo "alias k='kubectl'" >> /home/vagrant/.bashrc
