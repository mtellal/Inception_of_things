#!/bin/bash

# Define color codes
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "${GREEN}Creating k3d cluster 'mycluster'...${NC}"
k3d cluster create mycluster
kubectl create namespace dev

echo -e "${GREEN}Installing argocd...${NC}"
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo -e "${GREEN}Waiting for ArgoCD server to be ready...${NC}"
until kubectl -n argocd get pod -l app.kubernetes.io/name=argocd-server -o jsonpath="{.items[0].status.phase}" | grep -q "Running"; do
  sleep 1
done

echo -e "${GREEN}Patching ArgoCD ConfigMap to set polling interval to 1 minute...${NC}"
kubectl -n argocd patch configmap argocd-cm -p '{"data": {"repository.pollingInterval": "1m"}}'
kubectl -n argocd delete pod -l app.kubernetes.io/name=argocd-server
kubectl -n argocd wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server --timeout=300s

echo -e "${GREEN}Forward port svc/argocd-server 8080:443${NC}"
nohup kubectl port-forward svc/argocd-server -n argocd 8080:443 > /dev/null 2>&1 &

ARGO_PWD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

argocd login localhost:8080 --username admin --password $ARGO_PWD --insecure

argocd account update-password --current-password $ARGO_PWD --new-password admin123

while true; do
  argocd app create playground \
    --repo https://github.com/mtellal/argocd-config.git \
    --path dev/ \
    --dest-namespace dev \
    --dest-server https://kubernetes.default.svc \
    --sync-policy automated \
    --revision antbarbi && break
done

nohup bash -c 'while true; do kubectl port-forward svc/wil-app -n dev 8888:8888; sleep 5; done' > /dev/null 2>&1 &