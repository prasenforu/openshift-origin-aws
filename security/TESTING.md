## Test notes

```
oc login https://ocpmaster:8443 --token=$TOKEN

curl -u user:password -kI 'https://ocpmaster:8443/oauth/authorize?client_id=openshift-challenging-client&response_type=token' | grep -oP "access_token=\K[^&]*"
```
