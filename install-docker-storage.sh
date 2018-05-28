#!/bin/bash

# Install Openshift 3.6 packages

#ssh ose-master "yum -y install wget git net-tools bind-utils iptables-services bridge-utils pythonvirtualenv gcc bash-completion epel-release ansible"
#ssh ose-master "yum -y install wget git net-tools bind-utils iptables-services bridge-utils pythonvirtualenv gcc bash-completion"

# yum update on the master and all the nodes:

for node in {ose-master,ose-hub,ose-node1,ose-node2}; do
echo "Running yum update on $node" && \
ssh $node "echo 'nameserver 8.8.8.8' | sudo tee --append /etc/resolv.conf"
ssh $node "yum clean all"
ssh $node "yum repolist"
ssh $node "yum -y update"
ssh $node "yum install -y wget git net-tools bind-utils iptables-services bridge-utils pythonvirtualenv gcc bash-completion ansible kexec-tools sos psacct yum-utils"
done

# Disable Firewalld & enable Iptable

systemctl disable firewalld
systemctl stop firewalld

for node in {ose-master,ose-hub,ose-node1,ose-node2}; do
echo "Stoping and Disable Firewalld on $node" && \
ssh $node "systemctl disable firewalld"
ssh $node "systemctl stop firewalld"
ssh $node "systemctl status firewalld"
echo "Starting and Enable Iptable on $node"
ssh $node "systemctl enable iptables"
ssh $node "systemctl start iptables"
ssh $node "systemctl status iptables"
done

# Install docker in all hosts.

for node in {ose-master,ose-hub,ose-node1,ose-node2}; do
echo "Installing Docker on $node" && \
ssh $node "sudo yum -y install docker"
ssh $node "sed -i \"/^OPTIONS=/ s:.*:OPTIONS=\'--selinux-enabled --insecure-registry 172.30.0.0\/16\':\" /etc/sysconfig/docker"
#scp docker-storage-setup $node:/etc/sysconfig/docker-storage-setup
#ssh $node "docker-storage-setup"
ssh $node "systemctl enable docker"
ssh $node "systemctl start docker"
ssh $node "systemctl enable NetworkManager.service"
ssh $node "systemctl restart NetworkManager.service"
ssh $node "systemctl status NetworkManager.service"
done

# Docker Storage space check

#for node in {ose-master,ose-hub,ose-node1,ose-node2}; do echo "Status of Docker LV Storage on $node" && ssh $node "lvs | grep -v rhel"; done
#for node in {ose-master,ose-hub,ose-node1,ose-node2}; do echo "Status of Docker PV Storage on $node" && ssh $node "pvs | grep docker-vg"; done

# Rebooting servers

for node in {ose-master,ose-hub,ose-node1,ose-node2}; do
echo "Rebooting $node" && \
ssh $node reboot
done

echo "Waiting for servers up ...."
sleep 90
:
