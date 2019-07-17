# Openshift Event Watch
ocpwatch is a Kubernetes/Openshift watcher that currently publishes notification to available collaboration hubs/notification channels. Run it in Kubernetes/Openshift cluster, and get event notifications through webhooks.

### Installation

#### Step #1 Create a project & patch that project with node selector

```
oc new-project ocpwatch

oc patch namespace ocpwatch -p '{"metadata":{"annotations":{"openshift.io/node-selector":"region=infra"}}}'

oc adm policy add-scc-to-user anyuid system:serviceaccount:ocpwatch:ocpwatch
```

#### Step #2 Create a serviceaccount, role & clusterrole

```oc create -f ocpwatch-account.yaml```

#### Step #3 Create a configmap.

```
oc create -f ocpwatch-configmap.yaml
```
#### Step #4 Create Deployment

```oc create -f ocpwatch-deployment.yaml```

### Reference

- https://github.com/aananthraj/kubewatch 
- https://github.com/bitnami-labs/kubewatch 
