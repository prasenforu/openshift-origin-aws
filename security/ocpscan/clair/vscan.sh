#!/bin/bash
# This script will check Vulnerability of pod

LOGPATH=/log/output.log
DT=`date '+%d/%m/%Y %H:%M:%S'`

RESOURCE=`echo "$1" | jq  '.eventmeta .kind'  | sed 's/"//g'`
POD=`echo "$1" | jq  '.eventmeta .name'  | sed 's/"//g'`
NS=`echo "$1" | jq  '.eventmeta .namespace'  | sed 's/"//g'`
REASON=`echo "$1" | jq  '.eventmeta .reason'  | sed 's/"//g'`

TOKEN=`more $SERVICE_TOKEN_FILENAME`

if [ "$RESOURCE" == "pod" ] && [ "$REASON" == "Created" ]; then

   oc login https://$KUBEHOST:$KUBEPORT --token=$TOKEN --insecure-skip-tls-verify=true 1>/dev/null

   images_array=( `oc describe pod $POD -n $NS | grep Image: | awk "{print $2}"` )

   for image in "${images_array[@]}"
   do
      HIGH=`klar "$image" 2>/dev/null | grep  High: | cut -f2 -d " "`
      if [ $image != "" ] && [ $HIGH > 0 ]; then
        MSG="Image ($image) in POD ($POD) in Project ($NS) is a Vulnerable (High=$HIGH) image."
        echo "[ $DT ]  $MSG"
        echo "[ $DT ]  $MSG" >> $LOGPATH
      fi
   done

else
  exit
fi
