# Openshift Container Platform backup & Restore
 
###### Little script that will do a massive backup on OpenShift.
###### It will backup:

#### OpenShift Cluster

```
   oc export of ALL objects  >*.yaml
   (for easy restore of individual objects)
````

#### OpenShift Masters

- ETCD
- /etc/origin

#### OpenShift containers
Detect “mysql” container and starts mysqldump inside,
output saved to .sql file.
Detect “postgresql” container and starts pgdump inside.
And saves the backup:

If run inside a container (CronJob), then attach a PV to /backup.
If /backup is a git repo it will do a git commit for version controlled backups.

#### To Restore:

- Individual objects that where exported with oc export can be re-imported with 
```
oc create -f *.yaml
or 
oc replace -f *.yaml
```

-  ETCD dumps can be restored by putting files back into 
```
/var/lib/etcd
and 
restart etcd
```

-  OpenShift config files can be restored by putting them back into 
```
/etc/origin/master
and
 systemctl restart atomic-openshift-master-*
```

-  Mysqldumps can be restored by running 
```oc -n $PROJECT exec $POD — /usr/bin/sh -c ‘PATH=$PATH:/opt/rh/mysql55/root/usr/bin:/opt/rh/rh-mysql56/root/usr/bin/ mysql -h 127.0.0.1 -u $MYSQL_USER –password=$MYSQL_PASSWORD $MYSQL_DATABASE’ </backup/mysql/$PROJECT/$DC.sql
```

