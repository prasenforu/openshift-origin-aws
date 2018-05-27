#!/bin/bash

# Installing Packages for openshift

#yum -y install atomic-openshift-utils
yum install -y ansible
git clone https://github.com/openshift/openshift-ansible.git /root/openshift-ansible/

# Editing ansible host file

maspubip=`cat /tmp/master-pubip-$USER`

sed -i "s/XXXXXXXXX/$maspubip/g" myconfighost

# Run ansible playbook

# For 3.6 use below playbook for OCP installation
#ansible-playbook -i myconfighost /root/openshift-ansible/playbooks/byo/config.yml
# For 3.7 to 3.9 use below playbook for OCP installation
ansible-playbook -i myconfighost /root/openshift-ansible/playbooks/deploy_cluster.yml

# copy post OSE setup script
scp /root/openshift-origin-aws/post-ose-setup.sh  ose-master:/root/
scp /root/openshift-origin-aws/reset-ip.sh  ose-master:/root/
#scp /root/openshift-origin-aws/monitoring-deploy-script.sh ose-master:/root/
ssh ose-master 	"chmod 755 /root/post-ose-setup.sh"
ssh ose-master 	"chmod 755 /root/reset-ip.sh"
#ssh ose-master 	"chmod 755 /root/monitoring-deploy-script.sh"

# Rules add for monitoring 

for node in {ose-master,ose-hub,ose-node1,ose-node2}; do
echo "Adding iptables rules on $node" && \
ssh $node "iptables -A OS_FIREWALL_ALLOW -p tcp -m state --state NEW -m tcp --dport 9100 -j ACCEPT"
ssh $node "service iptables save"
done

ssh ose-master "iptables -A OS_FIREWALL_ALLOW -p tcp -m state --state NEW -m tcp --dport 9300 -j ACCEPT"
ssh ose-master "service iptables save"

ssh ose-hub "iptables -A OS_FIREWALL_ALLOW -p tcp -m state --state NEW -m tcp --dport 1936 -j ACCEPT"
ssh ose-hub "iptables -A OS_FIREWALL_ALLOW -p tcp -m state --state NEW -m tcp --dport 9093 -j ACCEPT"
ssh ose-hub "iptables -A OS_FIREWALL_ALLOW -p tcp -m state --state NEW -m tcp --dport 9090 -j ACCEPT"
ssh ose-hub "iptables -A OS_FIREWALL_ALLOW -p tcp -m state --state NEW -m tcp --dport 3000 -j ACCEPT"
ssh ose-hub "iptables -A OS_FIREWALL_ALLOW -p tcp -m state --state NEW -m tcp --dport 9000 -j ACCEPT"
ssh ose-hub "iptables -A OS_FIREWALL_ALLOW -p tcp -m state --state NEW -m tcp --dport 9300 -j ACCEPT"
ssh ose-hub "iptables -A OS_FIREWALL_ALLOW -p tcp -m state --state NEW -m tcp --dport 2379 -j ACCEPT"
ssh ose-hub "service iptables save"

# Solution for inter POD communication

#for node in {ose-node1,ose-node2}; do
#echo "Accept default iptable policies on $node" && \
#ssh $node "iptables -P INPUT ACCEPT"
#ssh $node "iptables -P FORWARD ACCEPT"
#ssh $node "iptables -P OUTPUT ACCEPT"
#echo ""
#echo "Flush the NAT and mangle tables on $node"
#ssh $node "iptables -t nat -F"
#ssh $node "iptables -t mangle -F"
#ssh $node "iptables -F"
#ssh $node "iptables -X"
#ssh $node "service iptables save"
#done

# Copy dokvgstat script to all node monitoring 

for node in {ose-master,ose-hub,ose-node1,ose-node2}; do
echo "Coping dokvgstat script on $node" && \
scp /root/openshift-origin-aws/dokvgstat.sh $node:/root/
ssh $node "chmod 755 /root/dokvgstat.sh"
done


# HAproxy metric image pull (NOT Required for 3.7 Onwards)

# ssh ose-hub "docker pull prom/haproxy-exporter"
#ssh ose-hub "docker pull prom/haproxy-exporter:v0.7.1"
