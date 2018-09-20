# Configure Prometheus Monitoring on Openshift Container Platform

## Overview
This Quick Start reference deployment guide provides step-by-step instructions for deploying Prometheus on OpenShift 

## Install & Configuring Prometheus

 ```
    ansible-playbook -i myconfighost /root/openshift-ansible/playbooks/openshift-prometheus/config.yml
 ```
Need to modify Prometheus configMap for Prometheus & Alermanager to enable our new rules for alerts. 

```
   git clone https://github.com/prasenforu/openshift-origin-aws.git
   cd openshift-origin-aws/prometheus/config
   dos2unix *
   cd prometheus/config
   oc project openshift-metrics
   oc delete cm prometheus
   
```

Edit Prometheus configmap as per requirement.

```
  vi prometheus-configmap.yaml
```

Edit Alermanager configmap as per requirement.

```
  vi alertmanager-configmap.yml
```

Now delete configMap for Alertmanager & Prometheus

```
   oc delete cm prometheus alertmanager
```

Next step create configMap for Alertmanager & Prometheus

```
   oc create -f prometheus-configmap.yaml
   oc create -f alertmanager-configmap.yml
   
```

After upload configmap restart Prometheus & Alertmanger service
```
   oc exec prometheus-0 -c prometheus -- curl -X POST http://localhost:9090/-/reload
   oc exec prometheus-0 -c alertmanger -- curl -X POST http://localhost:9093/-/reload
   
```

## Install & Configuring Grafana

```
    git clone https://github.com/prasenforu/openshift-grafana
    cd openshift-grafana
    oc new-project grafana --description="Grafana Dash board"
    oc new-app -f grafana-ocp.yaml
    oc expose svc grafana-ocp
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
