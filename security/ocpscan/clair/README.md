# Scan Your Docker Containers For Vulnerabilities

### Clair: Vulnerability Static Analysis for Containers

Here are the Kubernetes resources we are going to deploy to scan our images:

* "clairsecret" [secret](https://kubernetes.io/docs/concepts/configuration/secret/)
* "clairsvc" [service](https://kubernetes.io/docs/concepts/services-networking/service/)
* "clair" [ReplicationController](https://kubernetes.io/docs/concepts/workloads/controllers/replicationcontroller/)
* "clair-postgres" ReplicationController
* "postgres" service

#### Deployment in OCP

```
oc create secret generic clairsecret --from-file=./config.yaml
oc get secret
oc create -f clair-kubernetes.yaml
```
