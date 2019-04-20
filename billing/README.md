# Openshift Billing

Metering records historical cluster usage, and can generate usage reports showing usage breakdowns by pod or namespace over arbitrary time periods.
Data gathered from a perspective of operations is usually focused on a current window of time; the last hour, the last 24 hours, and/or the last 7 days. This is based on opensource tool ```operator-metering```

<p align="center">
  <img src="https://github.com/prasenforu/openshift-origin-aws/blob/master/billing/sample-report/metering.png">
</p>

## Installation

This installatation based on Openshit 3.11.

### Step #1

Create ```metering-custom.yaml``` file and edit following value based on output of command.

```
        htpasswdData: |
          testuser:{SHA}y/2sYAj5yrQIN4TL0YdPdmGNKpc=
        cookieSeed: "t6JA9vA0cv4up/BGyI47+L7yLKTpX1s7"
```
##### Step -A)

htpasswdData can contain htpasswd file contents for allowing auth using a static list of usernames and their password hashes.
Generate htpasswdData using: 

```htpasswd -nb -s testuser password123```

##### Step -B)

cookieSeed is used to protect the cookie created if accessing the API using browser.
Generate a 32 character random string using a command of your choice

```openssl rand -base64 32 | head -c32; echo```

### Step #2

Now we have to clone the ```operator-metering``` repo and set the release.

```
git clone https://github.com/operator-framework/operator-metering.git
git checkout 0.14.0 
```

#### Prerequistics 

This installation based on scripts are written in bash, and utilize a few non-standard tools ```faq``` to interact with yaml and json files. Please ensure you have the following tools installed before running the install scripts:

```
LATEST_RELEASE=$(curl -s https://api.github.com/repos/jzelinskie/faq/releases | cat | head -n 10 | grep "tag_name" | cut -d\" -f4)
curl -Lo /usr/local/bin/faq https://github.com/jzelinskie/faq/releases/download/$LATEST_RELEASE/faq-linux-amd64
chmod +x /usr/local/bin/faq
```

#### As we are going to install infra host, make sure Infra host should have more CPU and MEM (Presto Pod takes 2 GB memory and 2 core CPU as minimium). Otherwise Pod will not start.

### Step #3
Create a project ```ocp-metering``` using oc command.

```
export METERING_NAMESPACE=ocp-metering
export METERING_CR_FILE=metering-custom.yaml
oc new-project $METERING_NAMESPACE
```
Now edit/patch namespace, so all deployment goes to infra hosts.

```oc patch namespace ocp-metering -p '{"metadata":{"annotations":{"openshift.io/node-selector":"region=infra"}}}'```

### Step #4

Start deployment ..

```./hack/openshift-install.sh```

## Verification

In general it takes atleast 5 minutes to make ready all pods.

```
oc get pod

NAME                                  READY     STATUS    RESTARTS   AGE
hdfs-datanode-0                       1/1       Running   0          1m
hdfs-namenode-0                       1/1       Running   0          1m
hive-metastore-0                      1/1       Running   0          1m
hive-server-0                         1/1       Running   0          1m
metering-operator-5846ffb499-56x6v    2/2       Running   0          2m
presto-coordinator-7dbb8d7bc8-rg96v   1/1       Running   0          1m
reporting-operator-7d7b5dd77b-tr7tb   1/1       Running   0          1m
```

## Report creating

The Report custom resource is used to manage the execution and status of reports. Metering produces reports derived from usage data sources which can be used in further analysis and filtering.

A single Report resource represents a report which is updated with new information according to a schedule. Example Report will contain information on every Namespace's CPU/MEM/PVC usage, and will run immediate.

##### Note: Please change ```reportingStart & reportingEnd``` value.

```
oc create -f report-namespace-cpu.yaml
oc create -f report-namespace-mem.yaml
oc create -f report-namespace-pvc.yaml
```

#### Get the status of report

```oc get report```

#### Get report in csv or tabular format

```
curl -u testuser:password123 -k "https://<URL>/api/v1/reports/get?name=test-report-namespace&namespace=ocp-metering&format=tab"

curl -u testuser:password123 -k "https://<URL>/api/v1/reports/get?name=test-report-namespace&namespace=ocp-metering&format=csv"
```

## Uninstall

Uninstall also done through scripts and additionaly you need to delete pvc also.

```
export METERING_NAMESPACE=ocp-metering
export METERING_CR_FILE=metering-custom.yaml
./hack/openshift-uninstall.sh

oc get pvc
oc delete pvc <PVC names>
```
