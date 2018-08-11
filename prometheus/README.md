# Configure Monitoring on OCP

## Overview
This Quick Start reference deployment guide provides step-by-step instructions for deploying Prometheus on OpenShift 

## Install & Configuring Prometheus

 ```
    ansible-playbook -i myconfighost /root/openshift-ansible/playbooks/openshift-prometheus/config.yml
 ```
Need to modify Prometheus configMap to enable our new rules for alerts. 

```
   oc project openshift-metrics
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

### Update Prometheus configuration

We need to reload the configuration, for test environment we could just kill the Prometheus pod with the command:

```
oc delete pod prometheus-0 --grace-period=0 --force
```

But for production environment it is not a good idea just to kill Prometheus in order to reload the configuration, because you interrupt the monitoring. There is an alternative way, for this you need to submit an empty POST to Prometheus URL with the suffix “-/reload”. 

```
oc exec prometheus-0 -c prometheus -- curl -X POST http://localhost:9090/-/reload
```
## Uninstall Prometheus

 ```
    ansible-playbook -i myconfighost /root/openshift-ansible/playbooks/openshift-prometheus/uninstall.yml
 ```
