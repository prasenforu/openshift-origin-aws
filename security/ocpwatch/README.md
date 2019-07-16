# Openshift Event Watch
ocpwatch is a Kubernetes/Openshift watcher that currently publishes notification to available collaboration hubs/notification channels. Run it in Kubernetes/Openshift cluster, and get event notifications through webhooks.

### Installation

#### Step #1 Create a project & patch that project with node selector

```
oc new-project kubewatch

oc patch namespace kubewatch -p '{"metadata":{"annotations":{"openshift.io/node-selector":"region=infra"}}}'
```

#### Step #2 Create a serviceaccount, role & clusterrole

```oc create -f kubewatch-service-account.yaml```

#### Step #3 Create a configmap.

```
oc create -f kubewatch-configmap.yaml
```
#### Step #4 Create Deployment

```oc create -f kubewatch-deployment.yaml```
