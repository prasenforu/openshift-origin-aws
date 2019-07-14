## Audit O Alert in Openshift

Audit is a feature that logs requests at the API server level, these logs are output to a log file on the master node. This auditing called "Advance Audit" in Openshift. Advanced audit is an enhancement over the older basic audit. Whereas the basic audit logged all requests to an audit file, advanced audit allows administrators to write a policy file to specify a subset of requests that get logged. Advanced audit also offers a webhook which can be used to send audit logs to a log aggregator via http or https.

### Enable Audit in Openshift

Enable audit create lots of log based on audit policy so prepare the policy as much as less.

#### Step #1 Create a policy file

Write the policy file as per audit policy file (audit-policy.yaml)

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
- name: ocpscan
  cluster:
    server: http://ocpscan-service.security.svc.cluster.local:9000/hooks/scanner-hook
contexts:
- context:
    cluster: ocpscan
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

## OCPSCAN
Its a ```runtime alert``` mechanism based on advanced audit for Openshift Container Platform. 

  - Alert on anytype of authentication.
  - Alert on POD/container login.
  - Alert on any type of activity for secret, configmap objects.
  - Alert on any critical activity for RBAC, SCC (Security Context Constraints) & service objects.
  - Alert on project create and delete.
  - Alert on POD/container service account volume mount.

and so on ....

#### Step #1 Create a project & patch that project with node selector

```
oc new-project security

oc patch namespace security -p '{"metadata":{"annotations":{"openshift.io/node-selector":"region=infra"}}}'

oc label node ocphub1 region="infra" --overwrite

```

#### Step #2 Setting sufficiaent priviledge to that project

In security project we have to give sufficient priviledge to run containers.

```
oc adm policy add-scc-to-user privileged system:serviceaccount:security:ocpscan-sa
oc adm policy add-scc-to-user anyuid system:serviceaccount:security:ocpscan-sa

```

#### Step #3 Create a serviceaccount, role & clusterrole

```oc create -f ocpscan-account.yaml```

#### Step #4 Create a configmap and secret which consist of hooks & scripts files.

```
vi mailtemplate.txt
oc create cm ocpscan-hooks-configmap --from-file=./hooks.json
oc create cm ocpscan-scanscript-configmap --from-file=./scanner.sh
oc create cm ocpscan-mailbody-configmap --from-file=./mailtemplate.txt
oc create secret generic ocpscan-mail-secret --from-file=mailsend=mailsend.py
oc create cm ocpscan-promtail-configmap --from-file=./ocpscan-promtail-config.yaml
```

#### Step #5 Create PVC

```oc create -f ocpscan-pvc.yaml```

#### Step #6 Create Deployment

```oc create -f ocpscan-deployment.yaml```

#### Step #7 Create a service & route

```
oc create -f ocpscan-service.yaml
oc expose svc ocpscan-service --port=9001

```
#### Step #8 Verifying the installation

```
oc get all
oc logs -f <POD NAME> -c ocpscan
oc logs -f <POD NAME> -c log2browser
oc rsh -c ocpscan <POD NAME> 
oc rsh -c log2browser <POD NAME> 
```

In order to test that OCPSCAN is working correctly, you can launch a shell in a Pod. You should see a message in log2browser url.
