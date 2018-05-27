#!/bin/bash

# Customised Environment 

cd /root/openshift-origin-aws

# Domain Update - Please edt domain name XXXXXXX

sed -i 's/ose/ocp/g' cloud-cafe.in.db
mv cloudapps.cloud-cafe.in.db cloudapps.XXXXXXX.db
mv cloud-cafe.in.db XXXXXXX.db
sed -i 's/cloud-cafe.in/XXXXXXX/g' *

# Hostname Update

sed -i 's/ose/ocp/g' hostfile
sed -i 's/ose-master/ocp-master/g' *
sed -i 's/ose-hub/ocp-hub/g' *
sed -i 's/ose-node1/ocp-node1/g' *
sed -i 's/ose-node2/ocp-node2/g' *

# Adding more Hosts in for Loop (1-master,1-hub,3-nodes)

#sed -i 's/ocp-master,ocp-hub,ocp-node1,ocp-node2/ocp-master,ocp-hub,ocp-node1,ocp-node2,ocp-node3/g' *

# Adding more Hosts in for Loop (1-master,2-hub,3-etcd,3-nodes)

#sed -i 's/ocp-master,ocp-hub,ocp-node1,ocp-node2/ocp-master,ocp-hub1,ocp-hub2,ocp-etcd1,ocp-etcd2,ocp-etcd3,ocp-node1,ocp-node2,ocp-node3/g' *

# Adding more Hosts in for Loop Full HA  (3-master,2-hub,3-etcd,3-nodes)

#sed -i 's/ocp-master,ocp-hub,ocp-node1,ocp-node2/ocp-master1,ocp-master2,ocp-master3,ocp-hub1,ocp-hub2,ocp-etcd1,ocp-etcd2,ocp-etcd3,ocp-node1,ocp-node2,ocp-node3/g' *

