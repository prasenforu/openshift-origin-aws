# Demo and testing for Audit O Alert (AOA) using ocpscan

### Getting Token from POD & login.

```
TOKEN=`more /var/run/secrets/kubernetes.io/serviceaccount/token`
oc login https://ocpmaster:8443 --token=$TOKEN --insecure-skip-tls-verify=true
```

### Getting Token from Service account & login.

```
tn=`oc describe sa nmap-sa -n test-project | grep Tokens | awk '{print $2}'`
TOKEN=`oc describe secret $tn -n test-project | grep token: | cut -d ":" -f2 | awk '{$1=$1};1'`
oc login https://ocpmaster1:8443 --token=$TOKEN --insecure-skip-tls-verify=true
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

### Vulnerable Image deployment for testing

##### Create a Sample-app project

```oc new-project sample-app```

##### Deployment without vulnerable

```
oc create deployment juice-shop --image=bkimminich/juice-shop
oc expose deployment juice-shop --port=3000
oc expose service/juice-shop
```

##### Deployment with vulnerable

```
oc create deployment webgoat --image=danmx/docker-owasp-webgoat
oc expose deployment webgoat --port=8080
oc expose service/webgoat
```

