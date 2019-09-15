1. Deploy configmap yaml

        oc create cm automate-hooks-configmap --from-file=./hooks.json
        oc create cm automate-scale-configmap --from-file=./scale.sh
        oc create cm automate-pod-restart-configmap --from-file=./pod-restart.sh
        oc create cm automate-node-restart-configmap --from-file=./node-restart.sh
        oc create cm automate-sn-configmap --from-file=./sn.sh
        oc create cm automate-keypem-configmap --from-file=./prasen.pem
        oc create cm automate-kubeconfig-configmap --from-file=./admin.conf

2. Install Deployment

        oc create -f automate-deployment.yaml
        oc adm policy add-scc-to-user privileged -z automate

3. Add entry in alertmanager configmap

   a) Add in routes section

     ```
      routes:

      - match:
          severity: criticalpod
        receiver: restart-pod-prom
      - match:
          severity: criticalmq
        receiver: email-n-mq   
     ```        

   b) Add in receivers section

     ```   
    receivers:

    - name: 'restart-pod-prom'
      webhook_configs:
      - url: http://automate-service.openshift-monitoring.svc.cluster.local:9000/hooks/ocp-pod-restart-hook?in1=openshift-monitoring&in2=prometheus-0
    - name: 'email-n-mq'
      email_configs:
      - to: 'receiver mail id'
        send_resolved: true
      webhook_configs:
      - url: http://automate-service.openshift-monitoring.svc.cluster.local:9000/hooks/scale-hook?in1=test-n-demo&in2=rabbitmqsrv      
     ```
4. Add entry in promethus rule file
     
     ```
    - name: alertrules.apps
      rules:
      - alert: MQMessages
        expr: sum by (queue) (rabbitmq_queue_messages{name="rabbitmqsrv",queue="hello",vhost="/"}) >= 15
        for: 2m
        labels:
          severity: criticalmq
        annotations:
          messages: "Total number of messages in queue {{ $labels.queue }}  is  >= 15 (current value: {{ $value }}%)"
          severity: criticalmq
     ```
5. Restart alertmanager container

        oc exec prometheus-0 -c alertmanager -- curl -X POST http://localhost:9093/-/reload

6. Testing without incident

        curl http://172.30.200.104:9000/hooks/ocp-pod-restart-hook?in1=openshift-monitoring&in2=prometheus-0&status=firing

7. Check logs of webhook pod

        oc logs -f <webhook pod name>
