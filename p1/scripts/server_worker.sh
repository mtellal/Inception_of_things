#!/bin/bash

SERVER_IP=192.168.56.110
SERVER_WORKER_IP=192.168.56.111
INTERFACE=eth1

TOKEN_FILE=/home/vagrant/shared/node-token

echo "INSTALLING K3S IN AGENT MODE"
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="agent --server=https://$SERVER_IP:6443 --token-file=$TOKEN_FILE --node-ip=$SERVER_WORKER_IP --flannel-iface=$INTERFACE" sh -

echo "ADDING K ALIAS ...."
sudo -u vagrant bash -c 'echo "alias k='\''kubectl'\''" >> /home/vagrant/.bashrc'
source /home/vagrant/.bashrc