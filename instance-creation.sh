#!/bin/bash

# Instance Creation and docker volume setup

# Variable declare, please change as per your environment

iid=ami-24959b47
ity=t2.medium
knm=prasen
subprid=subnet-5861ed2e
subpuid=subnet-84f095e0
sgidm=sg-258d5642
sgidh=sg-3b59fe5c
sgidn=sg-7959fe1e
volsz=10
aza=ap-southeast-2a
azb=ap-southeast-2b
volg=volg

# MASTER Server

echo "Creating and Starting OSE MASTER Host .."

aws ec2 run-instances --image-id $iid --count 1 \
--instance-type $ity --key-name $knm --security-group-ids $sgidm \
--subnet-id $subpuid --private-ip-address 10.90.1.208 --associate-public-ip-address --output text > /tmp/master-ins-$USER

miid=`cat /tmp/master-ins-$USER | grep INSTANCES | awk '{print $7}' | cut -d "-" -f2 | cut -d '"' -f1`
aws ec2 create-tags --resources i-$miid --tags Key=Name,Value=OSE-MASTER

# HUB/Router Server

echo "Creating and Starting OSE HUB/Router Host .."

aws ec2 run-instances --image-id $iid --count 1 \
--instance-type $ity --key-name $knm --security-group-ids $sgidh \
--subnet-id $subpuid --private-ip-address 10.90.1.209 --associate-public-ip-address --output text > /tmp/hub-ins-$USER

hiid=`cat /tmp/hub-ins-$USER | grep INSTANCES | awk '{print $7}' | cut -d "-" -f2 | cut -d '"' -f1`
aws ec2 create-tags --resources i-$hiid --tags Key=Name,Value=OSE-HUB

# NDOE1 Server

echo "Creating and Starting OSE NODE-1 Host .."

aws ec2 run-instances --image-id $iid --count 1 \
--instance-type $ity --key-name $knm --security-group-ids $sgidn \
--subnet-id $subprid --private-ip-address 10.90.2.210 --output text > /tmp/node1-ins-$USER

n1iid=`cat /tmp/node1-ins-$USER | grep INSTANCES | awk '{print $7}' | cut -d "-" -f2 | cut -d '"' -f1`
aws ec2 create-tags --resources i-$n1iid --tags Key=Name,Value=OSE-NODE-1


# NDOE2 Server

echo "Starting OSE NODE-2 Host .."

aws ec2 run-instances --image-id $iid --count 1 \
--instance-type $ity --key-name $knm --security-group-ids $sgidn \
--subnet-id $subprid --private-ip-address 10.90.2.211 --output text > /tmp/node2-ins-$USER

n2iid=`cat /tmp/node2-ins-$USER | grep INSTANCES | awk '{print $7}' | cut -d "-" -f2 | cut -d '"' -f1`
aws ec2 create-tags --resources i-$n2iid --tags Key=Name,Value=OSE-NODE-2

echo "Waiting all Hosts in running state .."
sleep 90

# Setting up Volume

echo "Creating a volume for Master..."

aws ec2 create-volume --size $volsz --availability-zone $aza > /tmp/$volg-$aza-$USER
vid=`cat /tmp/$volg-$aza-$USER | awk '{print $6}' | cut -d "-" -f2 | cut -d '"' -f1`
sleep 20
aws ec2 create-tags --resources vol-$vid --tags Key=Name,Value=Docker-Storage-Master
aws ec2 attach-volume --volume-id vol-$vid --instance-id i-$miid --device /dev/sdf

echo "Creating a volume for Hub..."

aws ec2 create-volume --size $volsz --availability-zone $aza > /tmp/$volg-$aza-$USER
vid=`cat /tmp/$volg-$aza-$USER | awk '{print $6}' | cut -d "-" -f2 | cut -d '"' -f1`
sleep 20
aws ec2 create-tags --resources vol-$vid --tags Key=Name,Value=Docker-Storage-Hub
aws ec2 attach-volume --volume-id vol-$vid --instance-id i-$hiid --device /dev/sdf

echo "Creating a volume for Node-1..."

aws ec2 create-volume --size $volsz --availability-zone $azb > /tmp/$volg-$azb-$USER
vid=`cat /tmp/$volg-$azb-$USER | awk '{print $6}' | cut -d "-" -f2 | cut -d '"' -f1`
sleep 20
aws ec2 create-tags --resources vol-$vid --tags Key=Name,Value=Docker-Storage-Node-1
aws ec2 attach-volume --volume-id vol-$vid --instance-id i-$n1iid --device /dev/sdf

echo "Creating a volume for Node-2..."

aws ec2 create-volume --size $volsz --availability-zone $azb > /tmp/$volg-$azb-$USER
vid=`cat /tmp/$volg-$azb-$USER | awk '{print $6}' | cut -d "-" -f2 | cut -d '"' -f1`
sleep 20
aws ec2 create-tags --resources vol-$vid --tags Key=Name,Value=Docker-Storage-Node-2
aws ec2 attach-volume --volume-id vol-$vid --instance-id i-$n2iid --device /dev/sdf

aws ec2 describe-instances --instance-id i-$miid | grep INSTANCES | awk '{print $13}' > /tmp/master-pubip-$USER
