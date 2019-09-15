## MQ demo for autoscale

### Create Configmap

```
oc create cm mq-send-configmap --from-file=./send.py
oc create cm mq-receive-configmap --from-file=./receive.py
oc create cm mq-receiveall-configmap --from-file=./receiveall.py
```

### Create deployment

```oc create -f mq-deployment.yaml```

### MQ load test script

##### MQ Receiver script.

```
#!/bin/sh
for i in {1..50}
do
 curl http://rabbitmqclient.cloudapps.cloud-cafe.in/hooks/consumer
 sleep 2
 printf %s *
done
```

##### MQ Sender script.

```
#!/bin/sh
for i in {1..25}
do
 curl http://rabbitmqclient.cloudapps.cloud-cafe.in/hooks/producer
 sleep 2
 printf %s -
done
```

##### For Receive all messages

```curl http://rabbitmqclient.cloudapps.cloud-cafe.in/hooks/consumeall```

