#!/bin/bash

# Setting UP passwordless login from DNS server

for node in {ose-master,ose-hub,ose-node1,ose-node2}; do
echo "Deploy SSH Key on $node" && \
scp -i prasen.pem /root/.ssh/id_rsa.pub centos@$node:/home/centos/.ssh/id_rsa.pub_root
ssh centos@$node -i prasen.pem "sudo mv /home/centos/.ssh/id_rsa.pub_root /root/.ssh/authorized_keys"
ssh centos@$node -i prasen.pem "sudo chown root:root /root/.ssh/authorized_keys"
ssh centos@$node -i prasen.pem "sudo chmod 600 /root/.ssh/authorized_keys"
ssh centos@$node -i prasen.pem "sudo sed -i 's/#PermitRootLogin yes/PermitRootLogin yes/g' /etc/ssh/sshd_config"
ssh centos@$node -i prasen.pem "sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config"
ssh centos@$node -i prasen.pem "sudo sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/g' /etc/ssh/sshd_config"
ssh centos@$node -i prasen.pem "sudo service sshd restart"
done

# Rebooting servers

for node in {ose-master,ose-hub,ose-node1,ose-node2}; do
echo "Rebooting $node" && \
ssh $node reboot
done

echo "Waiting for servers up ...."
sleep 90

# Configuring Repo and setting network

for node in {ose-master,ose-hub,ose-node1,ose-node2}; do
echo "Deploy Openshift Repo on $node" && \
scp /root/openshift-origin-aws/open.repo $node:/etc/yum.repos.d/open.repo
ssh $node "echo 'nameserver 8.8.8.8' | sudo tee --append /etc/resolv.conf"
ssh $node "echo 'preserve_hostname: true' | sudo tee --append /etc/cloud/cloud.cfg"
ssh $node "rm /etc/hostname"
ssh $node "touch /etc/hostname"
ssh $node "echo '$node.cloud-cafe.in' | sudo tee --append /etc/hostname"
ssh $node "echo 'HOSTNAME=$node.cloud-cafe.in' | sudo tee --append /etc/sysconfig/network"
done

# Rebooting servers

for node in {ose-master,ose-hub,ose-node1,ose-node2}; do
echo "Rebooting $node" && \
ssh $node reboot
done

echo "Waiting for servers up ...."
sleep 90
