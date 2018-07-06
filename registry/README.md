# Harbor Registry
An Enterprise-class Container Registry Server based on Docker Distribution. 

## Overview
Harbor is an an open source trusted cloud native registry project that stores, signs, and scans content. Harbor extends the open source Docker Distribution by adding the functionalities usually required by users such as security, identity and management. Having a registry closer to the build and run environment can improve the image transfer efficiency. Harbor supports replication of images between registries, and also offers advanced security features such as user management, access control and activity auditing.


#### Installation

##### Step 1

```
wget https://storage.googleapis.com/harbor-releases/release-1.5.0/harbor-online-installer-v1.5.0.tgz

tar xvf harbor-online-installer-v1.5.0.tgz

curl -L https://github.com/docker/compose/releases/download/1.16.1/docker-compose-`uname -s`-`uname -m` -o /usr/local/sbin/docker-compose

chmod +x /usr/local/sbin/docker-compose
```
##### Step 2
```
vi harbor.cfg
```
###### Required parameters 
```
hostname: IP or DNS - Do NOT use localhost or 127.0.0.1 for the hostname.
ui_url_protocol: (http or https. Default is http)
db_password: (Default is root) - Change this password for any production use!
harbor_admin_password: (Default is Harbor12345) - Change this password for any production use!
```
###### For HTTPS configuration

###### Step A - Create your own CA certificate:

```
  openssl req \
    -newkey rsa:4096 -nodes -sha256 -keyout server.key \
    -x509 -days 365 -out server.crt
```
###### Step B - Move your CA certificate to folder (/root/cert/)

```
cp yourdomain.com.crt /root/cert/
cp yourdomain.com.key /root/cert/ 
```

###### Step C - Edit the file harbor.cfg , update the hostname and the protocol, and update the attributes ssl_cert and ssl_cert_key:

```
  #set hostname
  hostname = reg.yourdomain.com
  #set ui_url_protocol
  ui_url_protocol = https
  ......
  #The path of cert and key files for nginx, they are applied only the protocol is set to https 
  ssl_cert = /root/cert/yourdomain.com.crt
  ssl_cert_key = /root/cert/yourdomain.com.key
```

##### Step 3
##### NOTE: to Setup Notary "ui_url_protocol" should be "https" in harbor.cfg 
```
./install.sh --with-clair --with-notary
```

##### Step 4

Browse in host ip or DNS
```
user: admin
pass: Harbor1234 (default)
```
#### Managing Harbor

###### Stoping Harbor
```
docker-compose stop
```

###### Starting Harbor
```
docker-compose start
```

###### Reconfigure 
To change Harbor's configuration, first stop existing Harbor instance and update harbor.cfg. Then run prepare script to populate the configuration. Finally re-create and start Harbor's instance:

```
docker-compose down -v
vi harbor.cfg
prepare
docker-compose up -d
```
###### Removing Harbor's containers while keeping the image data and Harbor's database files on the file system:

```
docker-compose down -v
```

###### Removing Harbor's database and image data (for a clean re-installation):

```
rm -r /data/database
rm -r /data/registry
```

##### Example

```
docker login ns1.tcs-ally.tk
docker tag <image id> ns1.tcs-ally.tk/testocp/prom:v2.2.1
docker push ns1.tcs-ally.tk/testocp/prom:v2.2.1
docker tag <image id> ns1.tcs-ally.tk/testocp/kubewebhook:5.0
docker push ns1.tcs-ally.tk/testocp/kubewebhook:5.0
```

##### Reference

```
https://github.com/vmware/harbor/blob/master/docs/installation_guide.md
```
