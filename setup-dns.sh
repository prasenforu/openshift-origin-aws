#!/bin/bash

# This is "DNS" Installation script

echo 'nameserver 8.8.8.8' | sudo tee --append /etc/resolv.conf

# Install packages

sudo yum install -y yum-utils bind bind-utils rpcbind nfs-server nfs-lock nfs-idmap git wget unzip zip epel-release ansible
#sudo yum install -y yum-utils bind bind-utils rpcbind nfs-server nfs-lock nfs-idmap git wget unzip zip telnet
sudo yum -y install wget git net-tools bind-utils iptables-services bridge-utils pythonvirtualenv gcc bash-completion

sudo systemctl enable named
sudo systemctl start named

# Download (clone) openshift-aws from github

#mkdir -p /root/openshift-origin-aws
#git clone https://github.com/prasenforu/openshift-origin-aws.git /root/openshift-origin-aws/

# Setting and configuring DNS 

sudo cp /root/openshift-origin-aws/cloudapps.cloud-cafe.in.db /var/named/dynamic/cloudapps.cloud-cafe.in.db
sudo cp /root/openshift-origin-aws/cloud-cafe.in.db /var/named/dynamic/cloud-cafe.in.db
sudo rm /etc/named.conf
sudo cp /root/openshift-origin-aws/named.conf /etc/named.conf

sudo chgrp named -R /var/named
sudo chown named -R /var/named/dynamic
sudo restorecon -R /var/named
sudo chown root:named /etc/named.conf
sudo restorecon /etc/named.conf
sudo systemctl status named
sudo systemctl restart named
sudo systemctl status named

# Setting Network for hostname change

echo 'preserve_hostname: true' | sudo tee --append /etc/cloud/cloud.cfg
sudo rm /etc/hostname
sudo touch /etc/hostname
echo 'ns1.cloud-cafe.in' | sudo tee --append /etc/hostname
echo 'HOSTNAME=ns1.cloud-cafe.in' | sudo tee --append /etc/sysconfig/network

# Setting passwordless login

echo 'StrictHostKeyChecking no' | sudo tee --append /etc/ssh/ssh_config
sudo ssh-keygen -f /root/.ssh/id_rsa -N ''

# Setting up yum repo for openshift

sudo cp /root/openshift-origin-aws/open.repo /etc/yum.repos.d/open.repo
sudo yum clean all
sudo yum repolist
sudo yum -y update

# Install Docker and Docker-compose

sudo yum -y install docker
sudo systemctl enable docker
sudo systemctl start docker

sudo curl -L "https://github.com/docker/compose/releases/download/1.9.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

sudo cat /root/openshift-origin-aws/hostfile >> /etc/hosts
