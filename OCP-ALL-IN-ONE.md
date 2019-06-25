# Install Openshift 3.11 in single host


### Install packages

```
yum install -y docker wget git net-tools bind-utils iptables-services bridge-utils pythonvirtualenv gcc bash-completion ansible kexec-tools sos psacct yum-utils
yum install -y centos-release-openshift-origin311 dos2unix
```

### Start and stop services

```
sed -i "s/OPTIONS.*/OPTIONS='--selinux-enabled --insecure-registry 172.30.0.0\/16'/" /etc/sysconfig/docker

systemctl enable docker
systemctl start docker
systemctl status docker

systemctl disable firewalld
systemctl stop firewalld

systemctl enable NetworkManager.service
systemctl restart NetworkManager.service
```

### Passwordless login

```
ssh-keygen -f /root/.ssh/id_rsa -N ''

cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys
sudo chown root:root /root/.ssh/authorized_keys
sudo chmod 600 /root/.ssh/authorized_keys
sudo sed -i 's/#PermitRootLogin yes/PermitRootLogin yes/g' /etc/ssh/sshd_config
sudo sed -i 's/PermitRootLogin no/PermitRootLogin yes/g' /etc/ssh/sshd_config
sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sudo sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/g' /etc/ssh/sshd_config
echo 'StrictHostKeyChecking no' | sudo tee --append /etc/ssh/ssh_config
sudo service sshd restart
```

### PAckage Download

```
git clone https://github.com/prasenforu/openshift-origin-aws.git /root/openshift-origin-aws/
sleep 5
git clone https://github.com/openshift/openshift-ansible.git /root/openshift-ansible/
sleep 10

cd openshift-origin-aws
dos2unix *
cd /root/openshift-ansible/
git checkout release-3.11
cd /root/openshift-origin-aws/
```

### Prepare ansible hostfile

```
cp allinonehost allinonehost_bkp

sed -i "s/PPPPPPPP/<PUBLIC-IP>/g" allinonehost
sed -i "s/IIIIIIII/<INTERNAL-IP>/g" allinonehost

```

### Start Prerequistics

```ansible-playbook -i allinonehost /root/openshift-ansible/playbooks/prerequisites.yml```

### Start Installation

```ansible-playbook -i allinonehost /root/openshift-ansible/playbooks/deploy_cluster.yml```


### Post OCP setup

```
cp /etc/origin/master/master-config.yaml /etc/origin/master/master-config.yaml.original
htpasswd -b -c /etc/origin/master/htpasswd admin admin2675
htpasswd -b /etc/origin/master/htpasswd pkar pkar2675
```

### Providing admin rights to users (admin & pkar)

```
oc adm policy add-cluster-role-to-user cluster-admin pkar
oc adm policy add-cluster-role-to-user cluster-admin admin
oc adm policy add-scc-to-user privileged pkar
oc adm policy add-scc-to-user privileged admin
```
