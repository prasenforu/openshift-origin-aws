1. Deploy configmap yaml

        oc create cm automate-hooks-configmap --from-file=./hooks.json
        oc create cm automate-scale-configmap --from-file=./scale.sh
        oc create cm automate-pod-restart-configmap --from-file=./pod-restart.sh
        oc create cm automate-node-restart-configmap --from-file=./node-restart.sh
        oc create cm automate-sn-configmap --from-file=./sn.sh
        oc create cm automate-keypem-configmap --from-file=./prasen.pem
        oc create cm automate-kubeconfig-configmap --from-file=./admin.conf

2. Deploy POD

        oc create -f webhook-deployment.yaml
        oc adm policy add-scc-to-user privileged -z webhook

3. Add entry in alertmanager configmap


   a) Add in routes section

      routes:

      - match:
          severity: critical
        receiver: restart-pod-prom

   b) Add in receivers section

    receivers:

    - name: 'restart-pod-prom'
      webhook_configs:
      - url: http://172.30.200.104:9000/hooks/ocp-pod-restart-hook?in1=openshift-metrics&in2=prometheus-0


3. Restart alertmanager container

        oc exec prometheus-0 -c alertmanager -- curl -X POST http://localhost:9093/-/reload

4. Testing without incident

        curl http://172.30.200.104:9000/hooks/ocp-pod-restart-hook?in1=openshift-metrics&in2=prometheus-0&status=firing

5. Check logs of webhook pod


        oc logs -f <webhook pod name>
