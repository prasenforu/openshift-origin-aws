### Adding new custom rule in Prometheus

```
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
