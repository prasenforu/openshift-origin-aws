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
#### Step #3


#### Troubleshooting
