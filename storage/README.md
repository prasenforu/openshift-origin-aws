# Install Heketi and GlusterFS with Openshift to allow dynamic Persistent-Volume management

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

{
  "_port_comment": "Heketi Server Port Number",
  "port": "8080",

  "_use_auth": "Enable JWT authorization. Please enable for deployment",
  "use_auth": false,

  "_jwt": "Private keys for access",
  "jwt": {
    "_admin": "Admin has access to all APIs",
    "admin": {
      "key": "My Secret"
    },
    "_user": "User only has access to /volumes endpoint",
    "user": {
      "key": "My Secret"
    }
  },
  "_glusterfs_comment": "GlusterFS Configuration",
  "glusterfs": {
   "executor": "ssh",
   "sshexec": {
     "keyfile": "/etc/heketi/heketi_key",
     "user": "root",
     "port": "22",
     "fstab": "/etc/fstab"
   }
  },
  "_db_comment": "Database file name",
  "db": "/var/lib/heketi/heketi.db",
  "loglevel" : "debug"
  }
}

------



### 4. Configure Firewall access

 ##### a. Create /etc/firewalld/services/heketi.xml file for firewalld heketi service

----
<?xml version="1.0" encoding="utf-8"?> 
<service>
 <short>Heketi</short>
 <description>Heketi glusterfs REST API</description>
 <port protocol="tcp" port="8080"/>
</service>
----

 ##### b. Set proper right on the file

```
restorecon /etc/firewalld/services/heketi.xml
chmod 640 /etc/firewalld/services/heketi.xml
```

##### c. Add Heketi service into internal firewalld zone

````firewall-cmd --zone=internal --add-service=heketi --permanent```

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

TOPOLOGY : /root/topology-ocp.json

----

{
  "clusters": [
    {
      "nodes": [
        {
          "node": {
            "hostnames": {
              "manage": [
                "ocpgluster1"
              ],
              "storage": [
                "10.138.0.6"
              ]
            },
            "zone": 1
          },
          "devices": [
            "/dev/sdc"
          ]
        }
      ]
    }
  ]
}

-----

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

Vi storage-class-gluster.yml

---

storage-class-gluster.yml :

apiVersion: storage.k8s.io/v1beta1
kind: StorageClass
metadata:
  name: heketi
provisioner: kubernetes.io/glusterfs
parameters:
  resturl: "http://ocpmaster1:8080"
  restuser: "admin"
  restuserkey: "$PASSWORD_ADMIN"
  volumetype: "none"

---

##### 2. Create a PVC using the StorageCLass


vi testing-pvc.yml

apiVersion: v1
kind: PersistentVolumeClaim
metadata:
 name: heketi-pvc
 annotations:
   volume.beta.kubernetes.io/storage-class: heketi
spec:
 accessModes:
  - ReadWriteMany
 resources:
   requests:
     storage: 4Gi

---
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


#### ISSUE :

Warning  ProvisioningFailed  2s (x6 over 1m)  persistentvolume-controller  Failed to provision volume with StorageClass "heketi": failed to create volume: failed to create volume: Failed to allocate new volume: No space



HEKETI Commands: 


heketi-cli node list

heketi-cli node info <NODE-ID>

heketi-cli volume list
