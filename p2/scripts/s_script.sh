#!/bin/bash

INTERFACE=eth1
SERVER_IP=192.168.56.110

curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--node-ip=$SERVER_IP --flannel-iface=$INTERFACE --write-kubeconfig-mode=644" sh -

sudo -u vagrant bash -c 'echo "alias k='\''kubectl'\''" >> /home/vagrant/.bashrc'
source /home/vagrant/.bashrc

sudo -u vagrant bash -c 'kubectl apply -f /shared/'