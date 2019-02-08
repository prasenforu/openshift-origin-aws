# OpenShift Origin Active Directory Integration
Integrating OpenShift v3 with Microsoft Active Directory for user authentication. 
An Active Directory domain can be configured as an identity provider in OpenShift to provide centralized authentication. 
OpenShift can also utilize Active Directory groups for RBAC (Role Based Access Control).

#### Step #1 

An “admin” user account under OU (openshift) was created in the Active Directory domain to support the bind operation.

#### Step #2

Modify the OpenShift master configuration file (/etc/origin/master/master-config.yaml)

```
  identityProviders:
  - name: Active_Directory
    challenge: true
    login: true
    mappingMethod: claim
    provider:
      apiVersion: v1
      kind: LDAPPasswordIdentityProvider
      attributes:
        id:
        - dn
        email:
        - mail
        name:
        - cn
        preferredUsername:
        - uid
      bindDN: "cn=admin,ou=OpenShift,dc=tcs-ally,dc=tk"
      bindPassword: '<P A S S W O R D>'
      insecure: true
      url: "ldap://10.138.0.7:389/dc=tcs-ally,dc=tk?sAMAccountName"
  - challenge: true
    login: true
    mappingMethod: claim
    name: htpasswd_auth
    provider:
      apiVersion: v1
      file: /etc/origin/master/htpasswd
      kind: HTPasswdPasswordIdentityProvider
```

####### bindDN: "cn=admin,ou=OpenShift,dc=tcs-ally,dc=tk"

The common name of the openshift user account followed by the OU of the account and the domain name.

####### bindPassword: '<P A S S W O R D>'

The password of the openshift user account.

####### insecure: true
The setting for whether an insecure or secure communication should be used between the OpenShift master and the Domain Controller. 
The secure method requires the Domain Controller to utilize a SSL certificate for LDAPS.

####### url: "ldap://10.138.0.7:389/dc=tcs-ally,dc=tk?sAMAccountName"
The base search path for user accounts.

#### Step #3

Restart openshift master API & Controller

```
master-restart api

master-restart controllers
```

#### Step #4

Try to login from console with new user.

#### Step #5

After login, try get user from oc CLI.

```oc get users```

#### Troubleshooting

As part of the configuring OpenShift to make use of an LDAP server, it may be helpful to manually connect and perform queries against the server in order to validate the configurations.

There are several tools available that allow for browsing an LDAP server:

ldapsearch - Linux based command line query tool

###### a. Install ldapsearch

```yum install -y openldap-clients -y```

###### b. Put AD password in a variable

```PASS='P A S S W O R D'```

###### c. Search for a user

```ldapsearch -h 10.138.0.7 -p 389 -x -s base -b cn=admin,ou=Openshift,dc=tcs-ally,dc=tk```




