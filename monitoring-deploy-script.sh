#!/bin/sh

# Deployment script
# Run from Master

# Download repo from git
git clone https://github.com/prasenforu/openshift-monitoring.git

oc new-project prometheus
oc adm policy add-cluster-role-to-user cluster-reader system:serviceaccount:prometheus:default

oc patch project prometheus -p '{"metadata":{"annotations":{"openshift.io/node-selector":""}}}'

oc adm policy add-scc-to-user privileged system:serviceaccount:prometheus:default

oc adm manage-node ose-master.cloud-cafe.in --schedulable=true

oc create -f openshift-monitoring/node-exporter.yml

sleep 200

oc adm manage-node ose-master.cloud-cafe.in --schedulable=false

oc patch namespace prometheus -p '{"metadata":{"annotations":{"openshift.io/node-selector":"region=infra"}}}'
oadm policy add-scc-to-user anyuid -z default
