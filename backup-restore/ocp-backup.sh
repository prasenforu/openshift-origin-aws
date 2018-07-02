#!/bin/sh
# Openshift backup

DATE=`date +%Y%m%d.%H`
DIR=/backup/openshift

# cd /backup && git status
# [ $? != 0 ] && DIR=$DIR/$DATE
cd /backup
DIR=$DIR/$DATE

# Backup object per project for easy restore
mkdir -p $DIR/projects
cd $DIR/projects
for i in `oc get projects --no-headers |grep Active |awk '{print $1}'`
do 
  mkdir $i
  cd $i
  oc export namespace $i >ns.yml
  oc export project   $i >project.yml
  for j in pods replicationcontrollers deploymentconfigs buildconfigs services routes pvc quota hpa secrets configmaps daemonsets deployments endpoints imagestreams ingress scheduledjobs jobs limitranges policies policybindings roles rolebindings resourcequotas replicasets serviceaccounts templates oauthclients petsets
  do 
    mkdir $j
    cd $j
    for k in `oc get $j -n $i --no-headers |awk '{print $1}'`
    do
      echo export $j $k '-n' $i
      oc export $j $k -n $i >$k.yml
    done
    cd ..
  done
  cd ..
done

mkdir -p $DIR/global
cd $DIR/global
for j in cluster clusternetwork clusterpolicy clusterpolicybinding clusterresourcequota clusterrole clusterrolebinding egressnetworkpolicy group hostsubnet identity netnamespace networkpolicy node persistentvolumes securitycontextconstraints thirdpartyresource thirdpartyresourcedata user useridentitymapping
do 
  mkdir $j
  cd $j
  for k in `oc get $j -n $i --no-headers |awk '{print $1}'`
  do
    echo export $j $k '-n' $i
    oc export $j $k -n $i >$k.yml
  done
  cd ..
done

cd $DIR
# etcd database backup
etcdctl backup --data-dir /var/lib/etcd   --backup-dir etcd

# config files backup
mkdir files
rsync -va /etc/ansible/facts.d/openshift.fact \
          /etc/atomic-enterprise \
          /etc/corosync \
          /etc/ansible \
          /etc/etcd \
          /etc/openshift \
          /etc/openshift-sdn \
          /etc/origin \
          /etc/sysconfig/atomic-enterprise-master \
          /etc/sysconfig/atomic-enterprise-node \
          /etc/sysconfig/atomic-openshift-master \
          /etc/sysconfig/atomic-openshift-master-api \
          /etc/sysconfig/atomic-openshift-master-controllers \
          /etc/sysconfig/atomic-openshift-node \
          /etc/sysconfig/openshift-master \
          /etc/sysconfig/openshift-node \
          /etc/sysconfig/origin-master \
          /etc/sysconfig/origin-master-api \
          /etc/sysconfig/origin-master-controllers \
          /etc/sysconfig/origin-node \
          /etc/systemd/system/atomic-openshift-node.service.wants \
          /root/.kube \
          $HOME/.kube \
          /root/.kubeconfig \
          $HOME/.kubeconfig \
          /usr/lib/systemd/system/atomic-openshift-master-api.service \
          /usr/lib/systemd/system/atomic-openshift-master-controllers.service \
          /usr/lib/systemd/system/origin-master-api.service \
          /usr/lib/systemd/system/origin-master-controllers.service \
          /var/lib/etcd \
      files

### Databases ###
oc observe  --all-namespaces --once pods \
  -a '{ .metadata.labels.deploymentconfig }'   \
  -a '{ .metadata.labels.technology }'   \
  -a '{ .metadata.labels.backup     }'   -- echo \
 |grep -v ^# \
 |while read PROJECT POD DC TECH SCHEDULE
do
    [ "$SCHEDULE" == "" ] && continue
    #oc -n $PROJECT env --list $POD |tail -n +2`
    echo "$POD in $PROJECT want a $TECH $SCHEDULE backup"
    mkdir -p $DIR/../$TECH/$PROJECT  2>/dev/null
    case $TECH in
      mysql)
        oc -n $PROJECT exec $POD -- /usr/bin/sh -c 'PATH=$PATH:/opt/rh/mysql55/root/usr/bin:/opt/rh/rh-mysql56/root/usr/bin/ mysqldump -h 127.0.0.1 -u $MYSQL_USER --password=$MYSQL_PASSWORD $MYSQL_DATABASE' >$DIR/../mysql/$PROJECT/$DC.sql
        ;;
      postgresql)
        oc -n $PROJECT exec $POD -- /usr/bin/sh -c 'PATH=$PATH:/opt/rh/rh-postgresql94/root/usr/bin:/opt/rh/rh-postgresql95/root/usr/bin pg_dump $POSTGRESQL_DATABASE' >$DIR/../postgresql/$PROJECT/$DC.sql
        ;;
      *)
        echo "Unknown technology"
        ;;
    esac
    gzip $DIR/../mysql/$PROJECT/$DC.sql
done



### Persistent Volumes ###
#cd $DIR/../volumes
#mount -t glusterfs 192.168.0.20:vol_e22f1c43ac7556b3338ba400a61f719e /mnt/tmp/
#rsync -va /mnt/tmp/ uploads/
#umount /mnt/tmp
#mount -t glusterfs 192.168.0.20:pvc-b18c0d5d-eb28-11e6-9f5a-06f5e3517bb5 /mnt/tmp/
#rsync -va /mnt/tmp/ downloads/
#umount /mnt/tmp


cd /backup
#git status
#if [ $? == 0 ]; then
#  git add .
#  git commit -am "$DATE"
#  git push -u origin master
#else
#  # compress
#  cd $DIR/..
#  tar czvf ${DATE}.tgz $DATE
#  echo rm -r $DATE
#fi

# compress
cd $DIR/..
tar czvf ${DATE}.tgz $DATE
echo rm -r $DATE
