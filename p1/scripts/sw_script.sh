#!/bin/bash

SERVER_IP=192.168.56.110
WORKER_IP=192.168.56.111
INTERFACE=eth1

TOKEN_FILE=/shared/node-token

curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="agent --server https://$SERVER_IP:6443 --token-file=$TOKEN_FILE --node-ip=$WORKER_IP --flannel-iface=$INTERFACE" sh -