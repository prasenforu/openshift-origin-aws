# Openshift logging with Loki
Loki is a logging backend optimized for users running Prometheus and Kubernetes with great logs search and visualization in Grafana 6.0.

Loki was built for efficiency alongside the following goals:

- Logs should be cheap. Nobody should be asked to log less.
- Easy to operate and scale.
- Metrics, logs (and traces later) need to work together.

## Loki components
Loki is a TSDB (Time-series database), it stores logs as split and gzipped chunks of data.

The logs are ingested via the API and an agent, called Promtail (Tailing logs in Prometheus format), will scrape Kubernetes logs and add label metadata before sending it to Loki.

This metadata addition is exactly the same as Prometheus, so you will end up with the exact same labels for your resources.

## Logging architecture with Loki




### Install Loki in Openshift

```
oc new-project loki
oc adm policy add-scc-to-user privileged system:serviceaccount:loki:promtail
oc adm policy add-scc-to-user anyuid system:serviceaccount:loki:promtail
oc adm policy add-scc-to-user anyuid system:serviceaccount:loki:loki
oc patch namespace loki -p '{"metadata":{"annotations":{"openshift.io/node-selector":""}}}'
oc create -f loki.yaml
oc create -f promtail.yaml
```

### Install Loki outside of Openshift

```
docker run -d --name loki -p 3100:3100 --restart=always --volume " /root/loki:/etc/loki" grafana/loki -config.file=/etc/loki/loki-local-config.yaml

oc new-project loki
oc adm policy add-scc-to-user privileged system:serviceaccount:loki:promtail
oc adm policy add-scc-to-user anyuid system:serviceaccount:loki:promtail
oc patch namespace loki -p '{"metadata":{"annotations":{"openshift.io/node-selector":""}}}'
oc create -f promtail.yaml
```



