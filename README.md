# Openshift on AWS

## Overview
This Quick Start reference deployment guide provides step-by-step instructions for deploying OpenShift on the Amazon Web Services (AWS) cloud. 

## OpenShift & AWS Architecture
We will look at the OpenShift v3.x was created to reflect the additional information needed based on some key models below Docker, Kubernetes.

<p align="center">
  <img src="https://github.com/prasenforu/openshift-origin-aws/blob/master/aws-arc.PNG">
</p>

- DNS: The host that contain Red Hat OpenShift control components, including the API server and the controller manager server. The master manages nodes in its Kubernetes
- Master: The host that contain Red Hat OpenShift control components, including the API server and the controller manager server. The master manages nodes in its Kubernetes cluster and schedules pods to run on nodes.
- Hub: The host that contain Red Hat OpenShift registry, router and NFS. This server some people call as Infra Server. This server is important, we will point our wild card DNS “cloudapps.cloud-cafe.in” in godaddy.in in my domain configuration.
- Node1 and Node2: Nodes provide the runtime environments for containers. Each node in a Kubernetes cluster has the required services to be managed by the master. Nodes also have the required services to run pods, including Docker, a kubelet and a service proxy. 

## Prerequisites 
Before you deploy this Quick Start, we recommend that you become familiar with the following AWS services. (If you are new to AWS, see Getting Started with AWS.)

- Amazon Virtual Private Cloud (Amazon VPC)
- Amazon Elastic Compute Cloud (Amazon EC2)

It is assumes that familiarity with PaaS concepts and Red Hat OpenShift. For more information, see the OpenShift documentation.
If you want to access publically your openshift then you need registered domain. Here I use my domain (cloud-café.in) which I purchase from godaddy.in

##### Step #1	Use CentOS image for deployment of OpenShift
##### Step #2	Prepare an AWS Account
##### Step #3	Setup VPC

1.	Configure VPC with 10.90.0.0/16 CIDR	
(Do not use 10.1.0.0/16 or 10.128.0.0/14, this CIDR by default taken by OpenShift for internal communication), 
But there is option if you want to change, see the OpenShift documentation.
2.	Create two subnet (Private - 10.90.2.0/24  & Public 10.90.1.0/24)
3.	Create InternetGateWay (IGW)
4.	Create routing table for internet and associate public subnet and add route with Internet Gate Way
5.	Setup NatGateWay and assign public IP and select Public Subnet
6.	Then add route 0.0.0.0/0 source from NAT 
7.	Then go to association and add Private Subnet.

##### Step #4	Setup Security Group

** OSE-DNS-SG **

| Type | Protocol | Port Range | Source |
| ------ | ------ | ------ | ------ |
| HTTP | TCP | 80 | 0.0.0.0/0 |
| SSH | TCP | 22 | 0.0.0.0/0 |
| All traffic | All | All | 10.90.0.0/16 |
| HTTPS| TCP | 443 | 0.0.0.0/0 |

 ** OSE-MASTER-SG **
 
| Type | Protocol | Port Range | Source |
| ------ | ------ | ------ | ------ |
| HTTP | TCP | 80 | 0.0.0.0/0 |
| SSH | TCP | 22 | OSE-DNS-SG |
| All traffic | All | All | 10.90.0.0/16 |
| HTTPS| TCP | 443 | 0.0.0.0/0 |
| HTTPS| TCP | 8443 | 0.0.0.0/0 |

** OSE-HUB-SG **

| Type | Protocol | Port Range | Source |
| ------ | ------ | ------ | ------ |
| HTTP | TCP | 80 | 0.0.0.0/0 |
| SSH | TCP | 22 | OSE-DNS-SG |
| All traffic | All | All | 10.90.0.0/16 |
| HTTPS| TCP | 443 | 0.0.0.0/0 |
| HTTPS| TCP | 8443 | 0.0.0.0/0 |

** OSE-NODE-SG **

| Type | Protocol | Port Range | Source |
| ------ | ------ | ------ | ------ |
| HTTP | TCP | 80 | 0.0.0.0/0 |
| SSH | TCP | 22 | OSE-DNS-SG |
| All traffic | All | All | 10.90.0.0/16 |
| HTTPS| TCP | 443 | 0.0.0.0/0 |

## Deployment Steps

DNS is a requirement for OpenShift Enterprise. In fact most issues comes if you do not have properly working DNS environment.  As we are running in AWS so there is another complex because AWS use its own DNS server on their instances, we need to change make a separate DNS server and use in our environment.

### Preparation of custom DNS Environment in AWS

1.	Go to your VPC
2.	Choose your VPC from “Filter by VPC:”
3.	Click “DHCP Option Sets”
4.	Create DHCP Option Set 
5.	Give your domain name “cloud-café-in” in Domain name
6.	Give DNS server IP in Domain name servers.
7.	You can set NTP servers on same DNS server, give DNS server IP in NTP servers (optional).

### Now activate your DNS server for your VPC

1.	Now go to your VPC
2.	Choose your VPC from “Filter by VPC:”
3.	Click “Your VPCs”
4.	Select Openshift-VPC
5.	Click Action
6.	Then “Edit DHCP Option Set “
7.	Then Select what you created from earlier.

### Now launch an EC2 using CentOS community images ```ami-24959b47``` in Public Subnet with 10.90.1.78 ip 

Add below content in user data in Advance section.
```
#!/bin/bash
echo nameserver 8.8.8.8 >> /etc/resolv.conf
yum install git unzip dos2unix -y
```

Once DNS host is up and running, login on that dns host and make ready dns host for staring installation

### Clone packeges 
```
git clone https://github.com/prasenforu/openshift-origin-aws.git
cd openshift-origin-aws
dos2unix *
cd /root
git clone https://github.com/openshift/openshift-ansible.git /root/openshift-ansible/
cd openshift-ansible
git checkout release-3.9
```
### Add EC2 key-pair (add pem key content to prasen.pem file) & change prmission

```
chmod 400 prasen.pem
chmod 755 *.sh
```
### Edit install-aws-cli.sh (Add access-key & secret-access-key)

#### 1.	Setup DNS
```
	./setup-dns.sh
	reboot dns host
```
#### 2.	Install AWS CLI for Instance creation & Management
	Add access-key, secret-access-key & region in this file.
```
	./install-aws-cli.sh
```
#### 3. 	Now launch master, hub and nodes instance, there are two way.

###### a.	From console launch following instances with below details.

| Host | Private IP | Public IP | Security Group | Subnet |
| ------ | ------ | ------ | ------ | ------ |
| ose-master | 10.90.1.208 | Yes | OSE-MASTER-SG | Public |
| ose-hub | 10.90.1.209 | Yes |	OSE-HUB-SG | Public |
| ose-node1 | 10.90.2.210 | No | OSE-NODE-SG | Private |
| ose-node2 | 10.90.2.211 | No | OSE-NODE-SG | Private |

### OR

###### b. 	Create Instances (Master, Hub, Node1 & Node2) using AWS CLI
	You Can change script based on your requirement.
	(Type of host, volume size, etc.)
	
```
	./instance-creation.sh
```
#### 4. 	This script will do passwordless login & prepare all hosts
	### Note: Before running this script make sure you add your key-pair content in prasen.pem file
	
```
	./next-step1.sh 
```
#### 5.	This script will install & update packages and prepare docker storage in different volume
```
	./install-docker-storage.sh
```
#### 6.	Edit ansible host file
```
	vi myconfighost
		or
	vi myconfighost_etcd_ha
```
#### 7.	Starting OCP 3.9 Installation using ansible
```
	ansible-playbook -i myconfighost /root/openshift-ansible/playbooks/prerequisites.yml
	ansible-playbook -i myconfighost /root/openshift-ansible/playbooks/deploy_cluster.yml
```
#### 8.	After OSE 3.9 Installation, there few setup need to make environment ready
	Login authentication using htpassword, edit this file as per your requirement.
	
	### Note: This script need to run from ose-master host
	
```
	ssh ose-master
	./post-ose-setup.sh
```
### Installation & Configuration Prometheus on OCP
```
  ansible-playbook -i myconfighost /root/openshift-ansible/playbooks/openshift-prometheus/config.yml
```

### Uninstall OCP
```
  ansible-playbook -i myconfighost /root/openshift-ansible/playbooks/adhoc/uninstall.yml
```
### Check status from master host and get console URL
```
  oc get pods
  oc get all
  url=`more /etc/origin/master/master-config.yaml | grep publicURL`
  echo $url
```

### Exit container cleanup command

```
docker rm `docker ps -a | grep -v CONTAINER | grep Exited | awk '{print $1}'`

```
### Force delete pod command

```
kubectl delete pod NAME --grace-period=0 --force

```

### Permission denied on accessing host directory in docker

It is an selinux issue.

You can temporarily issue
```
su -c "setenforce 0"
```
OR

on the host to access or else add an selinux rule by running

```
chcon -Rt svirt_sandbox_file_t /path/to/volume
```

#### For security reason, you can delete access-key, secret-access-key and pem files

```
rm ~/.aws/config install-aws-cli.sh prasen.pem

```
#### Grafana Setup

```
ID=$(id -u)

mkdir -p /root/grafana/data

chcon -Rt svirt_sandbox_file_t /root/grafana/data

docker run -d --user $ID -p 3000:3000 --restart=always --name=grafana -e "GF_SECURITY_ADMIN_PASSWORD=admin2675" -v /root/grafana/data:/var/lib/grafana grafana/grafana
```

#### Prometheus Setup

```
mkdir /root/prom

chcon -Rt svirt_sandbox_file_t /root/prom

vi /root/prom/prometheus.yml

docker run -d -p 9090:9090 --restart=always --name prometheus -v /root/prom:/data -v /root/prom/prometheus.yml:/etc/prometheus/prometheus.yml prom/prometheus
```

#### MinIO Setup

```
mkdir -p /root/minio/data
mkdir -p /root/minio/config

chcon -Rt svirt_sandbox_file_t /root/minio/data
chcon -Rt svirt_sandbox_file_t /root/minio/config

docker run -d -p 9000:9000 --restart=always --name minio1 \
  -e "MINIO_ACCESS_KEY=AKIAIOSFODNN7EXAMPLE" \
  -e "MINIO_SECRET_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY" \
  -v /root/minio/data:/data \
  -v /root/minio/config:/root/.minio \
  minio/minio server /data
```

#### Splunk Setup

```
mkdir -p /root/splunk/etc
mkdir -p /root/splunk/var

chcon -Rt svirt_sandbox_file_t /root/splunk/etc
chcon -Rt svirt_sandbox_file_t /root/splunk/var

docker run -d -p 8000:8000 -p 8088:8088 --restart=always --name splunk --hostname splunk \
  -e "SPLUNK_START_ARGS=--accept-license" \
  -e "SPLUNK_PASSWORD=<password>" \
  -v /root/splunk/etc:/opt/splunk/etc \
  -v /root/splunk/var:/opt/splunk/var \
  splunk/splunk:7.3.0
```

# Feedback

We'll love to hear feedback and ideas on how we can make it more useful. Just create an issue.

Thanks !!
