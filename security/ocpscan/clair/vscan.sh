#!/bin/bash
# This script will check Vulnerability of pod

POD=yelb-ui-5946c9cfdb-wrpdb
NS=sample-app
KUBEHOST=10.138.0.16

TOKEN=`more $SERVICE_TOKEN_FILENAME`
oc login https://$KUBEHOST:$KUBEPORT --token=$TOKEN --insecure-skip-tls-verify=true 1>/dev/null

images_array=( `oc describe pod $POD -n $NS | grep Image: | awk "{print $2}"` )

for image in "${images_array[@]}"
do
   HIGH=`klar "$image" 2>/dev/null | grep  High: | cut -f2 -d " "`

   if [ $image != "" ] && [ $HIGH > 0 ]; then
     echo "Image ($image) in POD ($POD) in NS ($NS) is a Vulnerable (High=$HIGH) image."
   fi
done
