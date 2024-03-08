#!/bin/bash

# Load environment variables from .env file
source ../confs/config_file
PUB_KEY=$(cat ~/.ssh/id_rsa.pub)
sed -i "s|'your_public_key'|'$PUB_KEY'|g" ./install.sh
sed -i "s|"my_user_to_replace"|"$USER"|g" ./install.sh

echo "Downloading ubuntu 18.04 iso ..."

curl -o /mnt/nfs/homes/$USER/sgoinfre/ubuntu-18.04.6-desktop-amd64.iso https://releases.ubuntu.com/18.04/ubuntu-18.04.6-desktop-amd64.iso

echo "Creating virtual machine (mem: 2048, size: 20G) ..."

VBoxManage createvm --name $VM_NAME --register > /dev/null
VBoxManage modifyvm $VM_NAME  --ostype "Ubuntu_64" > /dev/null
VBoxManage modifyvm $VM_NAME  --memory 4096 --cpus 2 --vram 16 > /dev/null
VBoxManage modifyvm $VM_NAME  --nic1 nat --cableconnected1 on > /dev/null
VBoxManage modifyvm $VM_NAME --natpf1 "ssh,tcp,,2222,,22"
VBoxManage createmedium disk --filename "$DISK_PATH" --size 20000 > /dev/null
VBoxManage storagectl $VM_NAME --name "SATA Controller" --add sata --controller IntelAhci
VBoxManage storageattach $VM_NAME --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "$DISK_PATH"
VBoxManage storagectl $VM_NAME --name "IDE Controller" --add ide
VBoxManage storageattach $VM_NAME --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium "$ISO"

echo "Launching unattended install ..."

VBoxManage unattended install "$VM_NAME" \
--iso="$ISO" \
--additions-iso="$GUEST_ADDITIONS_ISO" \
--language="en_US" \
--user="$VM_USER" \
--password="$VM_USER_PASSWORD" \
--country="FR" \
--time-zone="UTC" \
--hostname="test.example.com" \
--install-additions \
--post-install-template="$POST_INSTALL_TEMPLATE"

VBoxManage startvm $VM_NAME --type headless

sed -i "s|'$PUB_KEY'|'your_public_key'|g" ./install.sh
sed -i "s|"$USER"|"my_user_to_replace"|g" ./install.sh
ssh-keygen -f "$HOME/.ssh/known_hosts" -R "[localhost]:2222"

echo "SSH connection awaiting ..."
while true; do
    ssh -o StrictHostKeyChecking=no -p 2222 $USER@localhost ls > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "SSH connection successful"
        break
    else
        sleep 5
    fi
done

scp -P 2222 ./launch_cluster.sh $USER@localhost:/home/$USER/launch_cluster.sh

ssh -p 2222 $USER@localhost bash /home/$USER/launch_cluster.sh

ssh -f -N -L 8080:localhost:8080 -p 2222 $USER@localhost

ssh -f -N -L 8888:localhost:8888 -p 2222 $USER@localhost
