# Demo and testing for Audit O Alert (AOA) using ocpscan

### Getting Token from POD & login.

```
TOKEN=`more /var/run/secrets/kubernetes.io/serviceaccount/token`

oc login https://ocpmaster:8443 --token=$TOKEN --insecure-skip-tls-verify=false

```

### Getting Token from Service account & login.

```
tn=`oc describe sa nmap-sa | grep Tokens | awk '{print $2}'`;
TOKEN=`oc describe secret $tn | grep token: | cut -d ":" -f2 | awk '{$1=$1};1'`

TOKEN=`more /var/run/secrets/kubernetes.io/serviceaccount/token`

oc login https://ocpmaster:8443 --token=$TOKEN --insecure-skip-tls-verify=false
```
           
### Authentiction using curl

```curl -u user:password -kI 'https://ocpmaster:8443/oauth/authorize?client_id=openshift-challenging-client&response_type=token' | grep -oP "access_token=\K[^&]*"```

### Creating secrets

```
curl -k -X POST -d @- -H "Authorization: Bearer $TOKEN" -H 'Accept: application/json' -H 'Content-Type: application/json' https://ocpmaster:8443/api/v1/namespaces/test-project/secrets <<'EOF'
{
  "kind": "Secret",
  
  "apiVersion": "v1",
  "metadata": {
    "name": "secret"
  },
  "stringData": {
    "NAME": "example"
  }
}
EOF
```
### Listing secrets

```curl -k -H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/json' https://ocpmaster:8443/api/v1/namespaces/test-project/secrets```



