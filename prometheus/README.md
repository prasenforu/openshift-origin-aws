# Configure Monitoring on OCP

## Overview
This Quick Start reference deployment guide provides step-by-step instructions for deploying Prometheus on OpenShift 

## Install & Configuring Prometheus

 ```
    ansible-playbook -i myconfighost /root/openshift-ansible/playbooks/openshift-prometheus/config.yml
 ```
Need to modify Prometheus configMap to enable our new rules for alerts. 

```
   oc edit cm prometheus
```
Now we will configure our mail client for the alert manager, edit configMap

```
   oc edit cm prometheus-alerts
```

## Install & Configuring Grafana

```
    git clone https://github.com/prasenforu/grafana-ocp
    cd grafana-ocp
    ./setup-grafana.sh prometheus-ocp openshift-metrics true
```

To configure Grafana to consume Prometheus, we will link grafana and openshift-metrics projects:
```
    oc adm pod-network join-projects --to=grafana openshift-metrics
```
For the authentication read management-admin service account token:
```
    oc sa get-token management-admin -n management-infra
```
Login to the Grafana dashboard and add new source:
```
    https://prometheus.openshift-metrics.svc.cluster.local
```
<p align="center">
  <img src="https://github.com/prasenforu/openshift-origin-aws/blob/master/prometheus/grafana-datasrote.png">
</p>

## Uninstall Prometheus

 ```
    ansible-playbook -i myconfighost /root/openshift-ansible/playbooks/openshift-prometheus/uninstall.yml
 ```
