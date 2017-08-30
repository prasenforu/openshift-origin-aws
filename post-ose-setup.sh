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
# oc patch namespace default -p '{"metadata":{"annotations":{"openshift.io/node-selector":"region=infra"}}}'

# Check it updated properly or not
oc get namespace default -o yaml

# Restart openshift services master

systemctl restart atomic-openshift-master
systemctl status atomic-openshift-master

# Setting Authentication openshift

htpasswd -b -c /etc/origin/master/users.htpasswd admin $admpas
htpasswd -b /etc/origin/master/users.htpasswd pkar $userpas

# Providing admin rights to users (admin & pkar)

oadm policy add-cluster-role-to-user cluster-admin pkar
oadm policy add-cluster-role-to-user cluster-admin admin
oadm policy add-scc-to-user privileged pkar
oadm policy add-scc-to-user privileged admin

# Setting Router for collect metrics

oc delete dc/router rc/router-1 svc/router 
oadm router router --replicas=1 --selector='region=infra' --service-account=router --images=openshift/origin-haproxy-router:v3.6.0 --metrics-image='prom/haproxy-exporter:v0.7.1' --expose-metrics 
