#!/bin/bash

# Post installation
# Change password as per your requirement

admpas=admin2675
userpas=pkar2675

# Backup config file
cp /etc/origin/master/master-config.yaml /etc/origin/master/master-config.yaml.original

# Get all nodes details

oc get nodes
oc get nodes --show-labels

# Set hosts proper levels

oc label node ose-hub.cloud-cafe.in region="infra" zone="infranodes" --overwrite
oc label node ose-node1.cloud-cafe.in region="primary" zone="east" --overwrite
oc label node ose-node2.cloud-cafe.in region="primary" zone="west"

# Check all nodes details are updated

oc get nodes
oc get nodes --show-labels

# Edit /etc/origin/master/master-config.yaml and Set defaultNodeSelector like defaultNodeSelector: "region=primary"

sed -i 's/  defaultNodeSelector: ""/  defaultNodeSelector: "region=primary"/' /etc/origin/master/master-config.yaml

# Set NodeSelector like node-selector: "region=infra" for pod (registry & route) deplyment
oc patch namespace default -p '{"metadata":{"annotations":{"openshift.io/node-selector":"region=infra"}}}'

# Check it updated properly or not
oc get namespace default -o yaml

# Restart openshift services master

systemctl restart atomic-openshift-master
systemctl status atomic-openshift-master

# Setting Authentication openshift

yum install -y httpd-tools
htpasswd -b -c /etc/origin/master/users.htpasswd admin $admpas
htpasswd -b /etc/origin/master/users.htpasswd pkar $userpas

# Then edit /etc/origin/master/master-config.yaml as follows
# -------
#identityProviders:
# - name: my_htpasswd_provider
# challenge: true
# login: true
# mappingMethod: claim
# provider:
# apiVersion: v1
#   kind: HTPasswdPasswordIdentityProvider
#   file: /etc/origin/master/users.htpasswd
# -------

# Please execute below command and In annotations section, 
# add the this line "openshift.io/node-selector: region=infra" in the default namespace object:
## oc edit namespace default
# Check it updated properly or not
## oc get namespace default -o yaml

# There are some security problem with router, 
# so need to delete router deployment then 
# Setup Router separately
# Then execute below command

oc delete dc/router rc/router-1 svc/router po/router-1-deploy dc/docker-registry rc/docker-registry-1 rc/docker-registry-2 svc/docker-registry sa/registry sa/router
echo '{"kind":"ServiceAccount","apiVersion":"v1","metadata":{"name":"registry"}}' | oc create -n default -f -
echo '{"kind":"ServiceAccount","apiVersion":"v1","metadata":{"name":"router"}}' | oc create -n default -f -
oadm policy add-cluster-role-to-user cluster-admin admin
oadm policy add-scc-to-user privileged system:serviceaccount:default:registry
oadm policy add-scc-to-user privileged system:serviceaccount:default:router
systemctl restart atomic-openshift-master
systemctl status atomic-openshift-master
oadm registry --service-account=registry --selector='region=infra'
#oadm router router --replicas=1 --selector='region=infra' --service-account=router --stats-password=admin2675
oadm router router --replicas=1 --selector='region=infra' --service-account=router --latest-images --expose-metrics --stats-password=admin2675
