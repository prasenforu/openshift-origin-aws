# OSE-Monitoring
Openshift Monitoring using GAP (Grafana Alertmanager Prometheus)

In this cutting edge technology new monitoring solutions based on completely open source. 
Monitor your infrastructure as well as container based platform using GAP with no cost as its opensource and customised as per your environment.

Grafana will give you nice dashboard.
Alertmanager will do alerting, you can send  alerts to mail, webhook, pageduty etc.
Prometheus is heart of monitoring which will do query also, so customised as per your choices.

Do auto scale based on ANY metric (cpu, memory, http etc.) 
Kubernetes/OSE support auto scale ONLY CPU based.

![Alt text](https://github.com/prasenforu/OSE-Monitoring/blob/master/GAParchitecture.png "Overview") 

### Openshift Prometheus Monitoring:

You have to have cluster-admin privileges on your Openshift Cluster to execute some of the following commands.
#### 1. Make sure, all your nodes are schedulable, as the node-exporter will not be created on a non-schedulable nodes.

```
	oc adm manage-node <NODEs> --schedulable=true
```
#### 2. Make sure, your nodes are reachable via IPV4 and IPV6, check the firewall rules. 
   Add following lines in /etc/sysconfig/iptables, and restart iptable services.
````
	iptables -A OS_FIREWALL_ALLOW -p tcp -m state --state NEW -m tcp --dport 9100 -j ACCEPT

	service iptables save		
	
````
   Additionally need to add few more rule for haproxy-exporter ONLY in hub's /etc/sysconfig/iptables

````
	iptables -A OS_FIREWALL_ALLOW -p tcp -m state --state NEW -m tcp --dport 9100 -j ACCEPT
	iptables -A OS_FIREWALL_ALLOW -p tcp -m state --state NEW -m tcp --dport 9101 -j ACCEPT
	iptables -A OS_FIREWALL_ALLOW -p tcp -m state --state NEW -m tcp --dport 9093 -j ACCEPT
	iptables -A OS_FIREWALL_ALLOW -p tcp -m state --state NEW -m tcp --dport 9090 -j ACCEPT
	iptables -A OS_FIREWALL_ALLOW -p tcp -m state --state NEW -m tcp --dport 3000 -j ACCEPT
	iptables -A OS_FIREWALL_ALLOW -p tcp -m state --state NEW -m tcp --dport 9000 -j ACCEPT
	
	service iptables save
````

#### 3. Configuring Prometheus

   First create the project and grant cluster-reader capabilities to the project's default serviceaccount, 
   as prometheus needs to be able to scrape API servers and nodes via HTTPS.

````
	oc new-project prometheus
	oc adm policy add-cluster-role-to-user cluster-reader system:serviceaccount:prometheus:default
````

   Please edit file (prometheus-alertrule-configmap.yml) for rules. 
   There are couple of script which will help to deploy,  undeploy and update confingmap file.

````	
	oc patch namespace prometheus -p '{"metadata":{"annotations":{"openshift.io/node-selector":"region=infra"}}}'
	cd prometheus
	./deploy-script.sh
````

#### 4. Configuring Alertmanager
  
   Please edit file (alertmanager-configmap.yml) for sending alert to mail. 
   There are couple of script which will help to deploy,  undeploy and update confingmap file.

````	
        cd alertmanager
	./deploy-script.sh
````

#### 5. Node exporter

   To gather node metrics, node-exporter is used. node-exporter instances can be started on every available node, 
    the projects's default node selector has to adjusted:

````    
	oc patch namespace prometheus -p '{"metadata":{"annotations":{"openshift.io/node-selector":""}}}'
````

   Then make the project's default user privileged, else node-exporter would not be able to gather all needed metrics:

````
	oc adm policy add-scc-to-user privileged system:serviceaccount:prometheus:default
````

   Last create the DaemonSet for the node-exporter:

````
	oc create -f node-exporter.yml
	oc patch namespace prometheus -p '{"metadata":{"annotations":{"openshift.io/node-selector":"region=infra"}}}'
````

#### 6. Download docker image haproxy-exporter in hub host 

   Delete old router (pod,svc,dc & rc)

````
	oc delete dc/router rc/router-1 svc/router po/router-1-deploy 
	docker pull prom/haproxy-exporter
	oadm router router --replicas=1 --selector='region=infra' --service-account=router --latest-images --expose-metrics --stats-password=#####
````

#### 7. Setting Grafana for Dashboard

   For setup Grafana with dashboard go to grafana folder and execute script. 
   There are couple of script which will help to deploy & undeploy.
   After that import dashboard go to dashboard folder and execute "import-grafana.sh" script. Please edit "import-grafana.sh" script as    per your requirements.

````
    cd grafana
    ./deploy-script.sh
    cd dashboard
    ./import-grafana.sh
````

#### 8. Configuring webhook
  
   Setup webhook for container/pod scale up or down based on ANY metric.
````	
        oc create -f webhook.yml
````

### Load Test

  For testing purpose I use abpache-benchmark tool. Download ab tool (yum -y install httpd)
  Using Apache Benchmark (the ab command) to simulate load on the application.

````
  yum -y install httpd		-  Download ab tool 
  ab -n 1000000 -c 75 <URL>
  ab -n 1000000 -c 75 http://memoryeater.cloudapps.cloud-cafe.in/	- in my case
  
````
