#!/bin/bash
# This script will check Vulnerability of pod
# and take action

LOGPATH=/log/output.log
DT=`date '+%d/%m/%Y %H:%M:%S'`
NSWL="/etc/webhook/nswhitelist.txt"
MAILID="Mail-ID"

RESOURCE=`echo "$1" | jq  '.eventmeta .kind'  | sed 's/"//g'`
POD=`echo "$1" | jq  '.eventmeta .name'  | sed 's/"//g'`
NS=`echo "$1" | jq  '.eventmeta .namespace'  | sed 's/"//g'`
REASON=`echo "$1" | jq  '.eventmeta .reason'  | sed 's/"//g'`

TOKEN=`more $SERVICE_TOKEN_FILENAME`

### OCP login and getiing Replication & Deployment

oc login https://$KUBEHOST:$KUBEPORT --token=$TOKEN --insecure-skip-tls-verify=true 1>/dev/null
REP=`oc describe pod $POD -n $NS | grep "Controlled By:" | awk '{print $3}'`
DEP=`oc describe $REP -n $NS | grep "Controlled By:" | awk '{print $3}'`

####### OCPSCAN ACTION #######

notify () {

MSG="Image in POD ($POD) in Project ($NS) is a Vulnerable image."
sed "s/MSG/$MSG/g" /etc/webhook/mailtemplate.txt > /etc/webhook/mailbody.txt
/etc/webhook/mailsend.py "ALERT: Security concern" "$MAILID"

}

#----- IGNORE FUNCTION ------#

ignore () {

while IFS= read -r line
do
  if [ "$NS" == "$line" ]; then
    echo $line
    exit
  fi
done < "$NSWL"

}

#----- SCALEDOWN POD FUNCTION ------#

scaledown () {

if [ "$DEP" != "" ]; then
  # Scale Down of POD using Deployment
  oc scale $DEP --replicas=0 -n $NS
elif [ "$REP" != "" ]; then
  # Scale Down of POD
  oc scale $REP --replicas=0 -n $NS
elif [ "$REP" == "" ] && [ "$DEP" == "" ]; then
  # Deleting POD as it has no controller
  oc delete pod $POD -n $NS
fi

}

###### Checking POD images for Vulnerable

if [ "$RESOURCE" == "pod" ] && [ "$REASON" == "Created" ]; then

   images_array=( `oc describe pod $POD -n $NS | grep Image: | awk "{print $2}"` )

   for image in "${images_array[@]}"
   do
      HIGH=`klar "$image" 2>/dev/null | grep  High: | cut -f2 -d " "`
      if [ $image != "" ] && [ $HIGH > 0 ]; then
        MSG="Image ($image) in POD ($POD) in Project ($NS) is a Vulnerable (High=$HIGH) image."
        echo "[ $DT ]  $MSG"
        echo "[ $DT ]  $MSG" >> $LOGPATH
        notify
        ignore
        scaledown
      fi
   done

else
  exit
fi
