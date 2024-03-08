#!/bin/bash

SERVER_IP=192.168.56.111
WORKER_IP=192.168.56.110
INTERFACE=eth1

TOKEN_FILE=/home/vagrant/shared/node-token

echo "INSTALLING K3S IN AGENT MODE"
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="agent --server=https://$SERVER_IP:6443 --token-file=$TOKEN_FILE --node-ip=$WORKER_IP --flannel-iface=$INTERFACE" sh -
