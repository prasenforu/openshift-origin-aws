#!/bin/bash

# Installing Packages for openshift

yum install -y ansible
git clone https://github.com/openshift/openshift-ansible.git /root/openshift-ansible/

# Editing ansible host file

maspubip=`cat /tmp/master-pubip-$USER`

sed -i "s/XXXXXXXXX/$maspubip/g" myconfighost

# Run ansible playbook

ansible-playbook -i myconfighost /root/openshift-ansible/playbooks/byo/config.yml

# copy post OSE setup script
scp /root/openshift-origin-aws/post-ose-setup.sh  ose-master:/root/
scp /root/openshift-origin-aws/reset-ip.sh  ose-master:/root/
scp /root/openshift-origin-aws/monitoring-deploy-script.sh ose-master:/root/
ssh ose-master 	"chmod 755 /root/post-ose-setup.sh"
ssh ose-master 	"chmod 755 /root/reset-ip.sh"
ssh ose-master 	"chmod 755 /root/monitoring-deploy-script.sh"

# Rules add for monitoring 

for node in {ose-master,ose-hub,ose-node1,ose-node2}; do
echo "Adding iptables rules on $node" && \
ssh $node "iptables -A OS_FIREWALL_ALLOW -p tcp -m state --state NEW -m tcp --dport 9100 -j ACCEPT"
ssh $node "service iptables save"
done

ssh ose-master "iptables -A OS_FIREWALL_ALLOW -p tcp -m state --state NEW -m tcp --dport 9300 -j ACCEPT"
ssh ose-master "service iptables save"

ssh ose-hub "iptables -A OS_FIREWALL_ALLOW -p tcp -m state --state NEW -m tcp --dport 9101 -j ACCEPT"
ssh ose-hub "iptables -A OS_FIREWALL_ALLOW -p tcp -m state --state NEW -m tcp --dport 9093 -j ACCEPT"
ssh ose-hub "iptables -A OS_FIREWALL_ALLOW -p tcp -m state --state NEW -m tcp --dport 9090 -j ACCEPT"
ssh ose-hub "iptables -A OS_FIREWALL_ALLOW -p tcp -m state --state NEW -m tcp --dport 3000 -j ACCEPT"
ssh ose-hub "iptables -A OS_FIREWALL_ALLOW -p tcp -m state --state NEW -m tcp --dport 9000 -j ACCEPT"
ssh ose-hub "iptables -A OS_FIREWALL_ALLOW -p tcp -m state --state NEW -m tcp --dport 9300 -j ACCEPT"
ssh ose-hub "iptables -A OS_FIREWALL_ALLOW -p tcp -m state --state NEW -m tcp --dport 2379 -j ACCEPT"
ssh ose-hub "service iptables save"

# Copy dokvgstat script to all node monitoring 

for node in {ose-master,ose-hub,ose-node1,ose-node2}; do
echo "Coping dokvgstat script on $node" && \
scp /root/openshift-origin-aws/dokvgstat.sh $node:/root/
ssh $node "chmod 755 /root/dokvgstat.sh"
done


# HAproxy metric image pull

# ssh ose-hub "docker pull prom/haproxy-exporter"
ssh ose-hub "docker pull prom/haproxy-exporter:v0.7.1"
