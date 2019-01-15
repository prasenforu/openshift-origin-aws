# Install Heketi and GlusterFS in Openshift 

Heketi provides a RESTful management interface which can be used to manage the life cycle of GlusterFS volumes. With Heketi, cloud services like OpenStack Manila, Kubernetes, and OpenShift can dynamically provision GlusterFS volumes with any of the supported durability types. Heketi will automatically determine the location for bricks across the cluster, making sure to place bricks and its replicas across different failure domains. Heketi also supports any number of GlusterFS clusters, allowing cloud services to provide network file storage without being limited to a single GlusterFS cluster.

##### Install Heketi on the MASTER_1 server :

### 1. Add epel release repository and install heketi
```
yum install -y epel-release
yum -y --enablerepo=epel install heketi heketi-client
```

### 2. Copy the ssh key created for ansible install to /etc/heketi/heket_key

```
cp /root/.ssh/id_rsa /etc/heketi/heketi_key
chown heketi: /etc/heketi/heketi_key
```

### 3. Backup original configuration & edit /etc/heketi/heketi.json config file

```
cp /etc/heketi/heketi.json /etc/heketi/heketi.json_ori
vi /etc/heketi/heketi.json
```

### 4. Configure Firewall access

 ##### a. Create /etc/firewalld/services/heketi.xml file for firewalld heketi service

```vi /etc/firewalld/services/heketi.xml```

 ##### b. Set proper right on the file

```
restorecon /etc/firewalld/services/heketi.xml
chmod 640 /etc/firewalld/services/heketi.xml
```

##### c. Add Heketi service into internal firewalld zone

```firewall-cmd --zone=internal --add-service=heketi --permanent```

##### d. Add an access to that zone for every node in the cluster

```firewall-cmd --zone=internal --add-source=<GLUSTER-NODE-IP>/32 --permanent```

##### e. Reload firewalld

```firewall-cmd --reload```

### 5. Start Heketi server
```
systemctl enable heketi
systemctl start heketi
systemctl status heketi
```

### 6. Setup Passwordless ssh from Master to Gluster Servers
```
[root@ocpmaster1]# ssh-keygen -f /root/.ssh/id_rsa -N ''
[root@ocpdns openshift-origin-aws]# scp ocpmaster1://root/.ssh/id_rsa.pub .
[root@ocpdns openshift-origin-aws]# scp id_rsa.pub ocpgluster1:/root/.ssh/id_rsa.pub_test
[root@ocpdns openshift-origin-aws]# ssh ocpgluster1
[root@ocpgluster1 ~]# cd /root/.ssh
[root@ocpgluster1 .ssh]# ll
total 16
-rw-------. 1 root root  393 Jan 10 11:42 authorized_keys
-rw-------. 1 root root 1679 Jan 14 16:26 id_rsa
-rw-r--r--. 1 root root  398 Jan 14 16:25 id_rsa.pub
-rw-r--r--. 1 root root  397 Jan 14 18:32 id_rsa.pub_test
[root@ocpgluster1 .ssh]# cat id_rsa.pub_test >> authorized_keys
```

### 7. Create the GlusterFS Cluster topology in file /root/topology-ocp.json

```vi /root/topology-ocp.json```

### 8. Now load topology json file

##### NOTE: Before execute command make sure "glusterd" daemon started in GLUSTER HOST (ocpgluster1), else start "glusterd" daemon in GLUSTER HOST (ocpgluster1)

```
[root@ocpgluster1 ~]# systemctl enable glusterd
[root@ocpgluster1 ~]# systemctl start glusterd
[root@ocpgluster1 ~]# systemctl status glusterd
```
```HEKETI_CLI_KEY="/etc/heketi/heketi_key";heketi-cli topology load --json=/root/topology-ocp.json --server http://ocpmaster1:8080 --user admin --secret $HEKETI_CLI_KEY```

Output will come as follows ...

Creating cluster ... ID: 73965a6e9cf0d85dde108b199d6bf511
        Allowing file volumes on cluster.
        Allowing block volumes on cluster.
        Creating node ocpgluster1 ... ID: 9a43ddccacd4029405cfa5b8f861fd5a
                Adding device /dev/sdc ... OK


### Now Glusterfs ready for provide gluster vloume for Openshift enviroment.

##### 1. Create a StorageClass 

```vi storage-class-gluster.yml```


##### 2. Create a PVC using the StorageCLass

```vi testing-pvc.yml```

Notice: This is by the annotation that you tell the PVC which storageclass to use

##### 3. Create objects in openshift 

```
oc create -f storage-class-gluster.yml -n default
oc create -f testing-pvc.yml
```

##### 4. Check if PVC is created running 

```oc get pvc```

### TESTING :

heketi-cli volume create --durability=none --size=1


#### ISSUE 1 (Unable to create node) :

HEKETI_CLI_KEY="/etc/heketi/heketi_key";heketi-cli topology load --json=/root/gluster-kubernetes/deploy/topology-ocp.json --server http://ocpmaster1:8080 --user admin --secret $HEKETI_CLI_KEY
Creating cluster ... ID: 14c5094b0dbbc6bf34608ae5c47fa121
        Allowing file volumes on cluster.
        Allowing block volumes on cluster.
        Creating node ocpgluster1 ... Unable to create node: New Node doesn't have glusterd running

####### Workaround/Solution: Setup passwordless ssh from master to gluster server.

#### ISSUE 2 (No space) :

heketi-cli setup-openshift-heketi-storage
Error: No space

When creating PVC it will show 

oc get pvc

NAME         STATUS    VOLUME    CAPACITY   ACCESS MODES   STORAGECLASS   AGE
heketi-pvc   Pending                                       heketi         1m

oc describe pvc heketi-pvc

Warning  ProvisioningFailed  2s (x6 over 1m)  persistentvolume-controller  Failed to provision volume with StorageClass "heketi": failed to create volume: failed to create volume: Failed to allocate new volume: No space

From this error response, it should be “obvious” because we have configured gluster server with single node. Apparently, this command has default replication factor of 3 and it cannot be changed.

####### Workaround/Solution: add 3rd node to cluster or use ```--durability=none```

```heketi-cli volume create --durability=none --size=1```

Also in storage-class-gluster.yml file need to add ``` volumetype: "none" ```


#### HEKETI Commands: 

```
heketi-cli node list
heketi-cli node info <NODE-ID>
heketi-cli volume list
```
