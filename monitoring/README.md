# Openshift Operation View
Openshift Operation View is a dashboard that allows you to get information on the capacity of your cluster among other things. 
This will help to identify issues in cluster.


### Installation of Openshift-ops-view 
```
oc new-project ocp-ops-view
oc patch namespace ocp-ops-view -p '{"metadata":{"annotations":{"openshift.io/node-selector":"region=infra"}}}'
oc create sa ocp-ops-view
oc adm policy add-scc-to-user anyuid -z ocp-ops-view
oc adm policy add-cluster-role-to-user cluster-reader system:serviceaccount:ocp-ops-view:ocp-ops-view
oc apply -f ocp-ops-view.yml
oc expose svc ocp-ops-view
oc get route | grep ocp-ops-view | awk '{print $2}'
```
