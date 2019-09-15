##### MQ demo for autoscale

### 

### Create Configmap

```
oc create cm mq-send-configmap --from-file=./send.py
oc create cm mq-receive-configmap --from-file=./receive.py
oc create cm mq-receiveall-configmap --from-file=./receiveall.py
```

### Create deployment

```oc create -f mq-deployment.yaml```

