# Audit & security in Openshift

Audit is a feature that logs requests at the API server level, these logs are output to a log file on the master node. This auditing called "Advance Audit" in Openshift. Advanced audit is an enhancement over the older basic audit. Whereas the basic audit logged all requests to an audit file, advanced audit allows administrators to write a policy file to specify a subset of requests that get logged. Advanced audit also offers a webhook which can be used to send audit logs to a log aggregator via http or https.

Container native security using ```Falco``` is an open source tool for intrusion and abnormality detection for Cloud Native platforms Kubernetes & Openshift. Detect abnormal application behavior. Alert via Slack, webhook & mail and more. Protect your platform by taking action through using automation.

### Enable Audit in Openshift

Enable audit create lots of log based on audit policy so prepare the policy as much as less.

#### Step #1 Create a policy file

Write the policy file below to /etc/origin/master/audit-policy.yaml.

```
apiVersion: audit.k8s.io/v1beta1
kind: Policy
rules:
  - level: Metadata
    userGroups: ["system:authenticated:oauth"]
    verbs: ["create", "delete"]
    resources:
      - group: "project.openshift.io"
        resources: ["projectrequests", "projects"]
    omitStages:
      - RequestReceived
```

#### Step #2 Create audit log folder.

Create a directory called /etc/origin/master/audit on the master. This directory will contain audit logs produced by advanced audit.

```mkdir /etc/origin/master/audit```

#### Step #3 Setting up webhook

Is a kubeconfig like file can be created to forward the logs to send logs to an aggregator external to OpenShift.

```vi /etc/origin/master/audit-webhook.yaml```

```
apiVersion: v1
kind: Config
clusters:
- name: falco
  cluster:
    server: http://$FALCO_SERVICE_CLUSTERIP:8765/k8s_audit
contexts:
- context:
    cluster: falco
    user: ""
  name: default-context
current-context: default-context
preferences: {}
users: []
```

#### Step #4 Edit master config file.

Modify or add below content in  /etc/origin/master/master-config.yaml to enable the auditing feature.

```
...
auditConfig:
  auditFilePath: /var/log/audit-ocp.log
  enabled: true
  maximumFileRetentionDays: 10
  maximumFileSizeMegabytes: 10
  maximumRetainedFiles: 10
  logFormat: json
  policyFile: /etc/origin/master/audit-policy.yaml
  webHookKubeConfig: /etc/origin/master/audit-webhook.yaml
  webHookMode: blocking
...

```

#### Step #5 Restart Api & controller service.

Restart the api server & check api and controllers are running.

```
master-restart api;master-restart controllers

oc get pod -n kube-system
```

#### Step #6 Testing

Let’s see what this looks like once everything is configured properly. Use the oc binary to create a new project.

```oc new-project test-project```

You can see logs geneted in audit logs file ```/var/log/audit-ocp.log```.

## Falco in Openshift

#### Step #1 Create a project & patch that project with node selector

```
oc new-project security

oc patch namespace security -p '{"metadata":{"annotations":{"openshift.io/node-selector":"security=falco"}}}'

oc label node ocphub1 security="falco" --overwrite
oc label node ocpmaster1 security="falco" --overwrite
oc label node ocpnode1 security="falco" --overwrite

```

#### Step #2 Setting sufficiaent priviledge to that project

In security project we have to give sufficient priviledge to run containers (as a DaemonSet in all nodes)

```oc adm policy add-scc-to-user privileged system:serviceaccount:security:falco-account```

#### Step #3 Create a serviceaccount, role & clusterrole

```oc create -f falco-service.yaml```

#### Step #4 Create a configmap which consist of falco rules, kubernetes audit rule & falco config file.

```oc create configmap falco-config --from-file=./falco-config```

#### Step #5 Deploy DaemonSet 

```oc create -f falco-daemonset-configmap.yaml```

#### Step #5 Verifying the installation

In order to test that Falco is working correctly, you can launch a shell in a Pod. You should see a message in your webhook or in the logs of the Falco pod.

### Notes

#### Create a own webhook url

```docker run -it --rm --init -p 80:80 -d --name webhook_site prasenforu/webhook.site```

#### nmap tool deployment

```oc create -f nmap.yaml```

#### Log output to browser

```docker run -d -p 9001:9001 -P --restart=always -v /root/webhook:/log prasenforu/log2browser /log/output.log```


