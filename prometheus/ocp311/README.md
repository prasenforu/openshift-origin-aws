### Adding new custom rule in Prometheus

```
oc project openshift-monitoring
oc create -f prom-custom-rule.yaml
```

### Adding or editing Alertmanager config file.
#### NOTE: Make sure you download jq tool (```yum -y --enablerepo=epel install jq```)

#### 1. Download existing alertmanager config file

```
oc get secret alertmanager-main -ojson | jq -r '.data["alertmanager.yaml"]' | base64 -d > alertmanager.yaml
```

#### 2. Edit that alertmanager config file as per requirement

```
vi alertmanager.yaml
```

#### 3. Replace alertmanager config

```
oc create secret generic alertmanager-main --from-literal=alertmanager.yaml="$(< alertmanager.yaml)" --dry-run -oyaml | oc replace secret --filename=-
```

#### To create standalone Grafana 

If you want to add k8s-prometheus as a datasource in this standalone Grafana, you need to run gfollowing command to get credentials.

```oc get secret grafana-datasources -n openshift-monitoring -o yaml | grep prometheus.yaml | cut -d':' -f2 | cut -d' ' -f2 | base64 -d```

if you to save in file run as follows ...

```oc get secret grafana-datasources -n openshift-monitoring -o yaml | grep prometheus.yaml | cut -d':' -f2 | cut -d' ' -f2 | base64 -d > datasource.yaml```
