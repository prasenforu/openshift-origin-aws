# Openshift Container Platform backup & Restore using Velero (heptio ark)

Velero (Heptio Ark) is a convenient backup tool for Openshift/Kubernetes clusters that compresses and backs up Kubernetes objects to object storage. It also takes snapshots of your cluster's Persistent Volumes using your cloud provider's block storage snapshot features, and can then restore your cluster's objects and Persistent Volumes to a previous state.
 
## Installation

The Heptio Ark backup tool consists of a client installed on your local computer and a server that runs in your Kubernetes cluster. To begin, we'll install the local Ark client.

#### Step #1 Create backup location

First you need to create backup location, it could be any cloud provider object storage location. But here I am going to use on-prem storage location. ```MinIO``` is one of opensource tool which hep you to create object storage like AWS S3. To setup ```MinIO``` use following steps.

```
mkdir -p /root/minio/data
mkdir -p /root/minio/config

chcon -Rt svirt_sandbox_file_t /root/minio/data
chcon -Rt svirt_sandbox_file_t /root/minio/config

docker run -d -p 9000:9000 --restart=always --name minio1 \
  -e "MINIO_ACCESS_KEY=AKIAIOSFODNN7EXAMPLE" \
  -e "MINIO_SECRET_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY" \
  -v /root/minio/data:/data \
  -v /root/minio/config:/root/.minio \
  minio/minio server /data
```
##### NOTE: Please do remember ```MINIO_ACCESS_KEY``` & ```MINIO_SECRET_KEY``` which we will use in future deployment.

Now you can access MinIO http://<serverIP>:9000. You can login using ```MINIO_ACCESS_KEY``` & ```MINIO_SECRET_KEY```.
 
Please create ```arkbucket-one``` bucket inside minio & and change policy with read & write also please do remember bucket name.

#### Step #2 Download packege

Download packege with wget

```NOTE: To follow this guide, you should download and install v0.10.0 of the Ark client.```

```
mkdir /root/bkp-restore
cd bkp-restore
wget https://github.com/heptio/velero/releases/download/v0.10.0/ark-v0.10.0-linux-amd64.tar.gz
tar zxvf ark-v0.10.0-linux-amd64.tar.gz
cp ark /usr/local/bin/ark
```

#### Step #3 Edit BackupStorageLocation object

Now we are ready to configure the Ark server and deploy it in our Openshift/Kubernetes cluster.

Before we deploy Ark into our Openshift/Kubernetes cluster, we'll first create Ark's prerequisite objects. 

- A heptio-ark Namespace
- The ark Service Account
- Role-based access control (RBAC) rules to grant permissions to the ark Service Account
- Custom Resources (CRDs) for the Ark-specific resources: Backup, Schedule, Restore, Config

Now we need to modify some configuration as per our requirement.

 - Edit BackupStorageLocation object
 
 ```
 cd config
 cp minio/05-ark-backupstoragelocation.yaml 05-ark-backupstoragelocation.yaml_bkp
 vi minio/05-ark-backupstoragelocation.yaml
```

Edit as follows ..

```
apiVersion: v1
kind: Secret
metadata:
  namespace: heptio-ark
  name: cloud-credentials
stringData:
  cloud: |
    [default]
    aws_access_key_id = AKIAIOSFODNN7EXAMPLE
    aws_secret_access_key = wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
---
apiVersion: ark.heptio.com/v1
kind: BackupStorageLocation
metadata:
  name: default
  namespace: heptio-ark
spec:
  provider: aws
  objectStorage:
    bucket: arkbucket-one
  config:
    region: minio
    s3ForcePathStyle: "true"
    s3Url: http://10.138.0.2:9000
```

#### Step #4 Start deployment

```
oc create -f common/00-prereqs.yaml
oc create -f minio/05-ark-backupstoragelocation.yaml
oc create -f minio/20-ark-deployment.yaml
oc create -f minio/30-restic-daemonset.yaml
```

#### Step #5 Verification

```
oc get pod
oc logs -f <POD NAME>

ark backup-location get
```


### BACKUP:

- OpenShift object

```
ark backup create velero-bkp --include-namespaces default

ark backup describe velero-bkp

ark backup logs velero-bkp
```

### RESTORE:



