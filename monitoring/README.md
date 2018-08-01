# Openshift Operation View
Openshift-ops-view features a dashboard that allows you to get information on the capacity of your cluster among other things. 


### Installation of Openshift-ops-view 
```
oc new-project ocp-ops-view
oc patch namespace ocp-ops-view -p '{"metadata":{"annotations":{"openshift.io/node-selector":"region=infra"}}}'
oc create sa kube-ops-view
oc adm policy add-scc-to-user anyuid -z kube-ops-view
oc adm policy add-cluster-role-to-user cluster-admin system:serviceaccount:ocp-ops-view:kube-ops-view
oc apply -f https://raw.githubusercontent.com/raffaelespazzoli/kube-ops-view/ocp/deploy-openshift/kube-ops-view.yaml
oc expose svc kube-ops-view
oc get route | grep kube-ops-view | awk '{print $2}'
```
