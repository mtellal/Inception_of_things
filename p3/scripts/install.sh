#!/usr/bin/env bash

# Redirect stdout ( > ) and stderr ( 2> ) into a named pipe ( >() ) running "tee"
exec > >(tee -i /target/root/vboxpostinstall.log) 2>&1

echo "Starting post-install script..."

cp /etc/resolv.conf /target/etc/resolv.conf

chroot /target /bin/bash <<'EOF'
VM_USER="my_user_to_replace"
GREEN='\033[0;32m'
NO_COLOR='\033[0m'

echo -e "${GREEN}Installing curl, vim, net-tools, openssh-server ...${NO_COLOR}\n"
apt update 
apt-get install -y curl vim net-tools openssh-server 

echo -e "\n${GREEN}Installing docker ...${NO_COLOR}\n"
apt install apt-transport-https ca-certificates curl software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=$(dpkg --print-architecture)] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-cache policy docker-ce
apt install docker-ce -y

echo -e "\n${GREEN}Adding current user to groups sudo, docker ...${NO_COLOR}\n"
### Adding user to groups
usermod -aG sudo $VM_USER
usermod -aG docker $VM_USER

echo -e "\n${GREEN}Installing kubectl ...${NO_COLOR}\n"
curl -LO "https://dl.k8s.io/release/$(curl -L https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x ./kubectl
mv ./kubectl /usr/local/bin/kubectl

echo -e "\n${GREEN}Installing K3D ...${NO_COLOR}\n"
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash > /dev/null

echo -e "\n${GREEN}Adding k alias ...${NO_COLOR}\n"
echo "alias k='kubectl'" >> /root/.bashrc
echo "alias k='kubectl'" >> /home/$VM_USER/.bashrc

echo -e "\n${GREEN}Installing ArgoCD CLI ...${NO_COLOR}\n"
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64

echo -e "\n${GREEN}Copying sshkey ...${NO_COLOR}\n"

mkdir -p /home/$VM_USER/.ssh
echo 'your_public_key' > /home/$VM_USER/.ssh/authorized_keys
chmod 700 /home/$VM_USER/.ssh
chmod 600 /home/$VM_USER/.ssh/authorized_keys
chown -R $VM_USER:$VM_USER /home/$VM_USER/.ssh

EOF

