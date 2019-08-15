#!/bin/sh
# This script will check Vulnerability and
# risks of pod and take action (Ignore, scaldown & delete)
# Use MAILID, SCALEDOWN & DELETE as an Env in deployment.

LOGPATH=/log/output.log
DT=`date '+%d/%m/%Y %H:%M:%S'`
NSWL="/etc/webhook/nswhitelist.txt"
#MAILID="RECEIVER MAIL ID"
#SCALEDOWN=Y
#DELETE=N

alias scan='sh /usr/bin/scan.sh'

RESOURCE=`echo "$1" | jq  '.eventmeta .kind'  | sed 's/"//g'`
POD=`echo "$1" | jq  '.eventmeta .name'  | sed 's/"//g'`
NS=`echo "$1" | jq  '.eventmeta .namespace'  | sed 's/"//g'`
REASON=`echo "$1" | jq  '.eventmeta .reason'  | sed 's/"//g'`

TOKEN=`more $SERVICE_TOKEN_FILENAME`

####### OCPSCAN ACTION #######

notify () {

MSG="POD ($POD) in Project ($NS) has $MSG1."
sed -e "s/MSG/$MSG/g" /etc/webhook/mailtemplate.txt > /etc/webhook/mailbody.txt
/etc/webhook/mailsend.py "ALERT: Security concern" "$MAILID"

}

#----- IGNORE FUNCTION ------#

ignore () {

while IFS= read -r line
do
  if [ "$NS" == "$line" ]; then
    exit
  fi
done < "$NSWL"

}

#----- SCALEDOWN POD FUNCTION ------#

scaledown () {

if [ "$SCALEDOWN" = "y" ] || [ "$SCALEDOWN" = "Y" ]; then

   if [ "$DEP" != "" ]; then
     # Scale Down of POD using Deployment
     oc scale $DEP --replicas=0 -n $NS
   elif [ "$REP" != "" ]; then
     # Scale Down of POD
     oc scale $REP --replicas=0 -n $NS
   else
     # Deleting POD as it has no controller
     oc delete pod $POD -n $NS
   fi

fi

}

#----- DELETING POD FUNCTION ------#

eliminate () {

if [ "$DELETE" = "y" ] || [ "$DELETE" = "Y" ]; then

   if [ "$DEP" != "" ]; then
     # Deleting Deployment
     oc delete $DEP -n $NS
   elif [ "$REP" != "" ]; then
     # Deleting Replicaset/Replicationcontroller/Statefullset
     oc delete $REP -n $NS
   else
     # Deleting POD as it has no controller
     oc delete pod $POD -n $NS
   fi

fi

}

###### Checking POD images for Vulnerable and risky POD

if [ "$RESOURCE" == "pod" ] && [ "$REASON" == "Created" ]; then

   ### OCP login and getTing Replication & Deployment

   oc login https://$KUBEHOST:$KUBEPORT --token=$TOKEN --insecure-skip-tls-verify=true 1>/dev/null
   REP=`oc describe pod $POD -n $NS | grep "Controlled By:" | awk '{print $3}'`
   DEP=`oc describe $REP -n $NS | grep "Controlled By:" | awk '{print $3}'`
   SA=`oc get pod $POD -n $NS -o yaml | grep serviceAccount: | awk '{print $2}'`
   images_array=`oc describe pod $POD -n $NS | grep Image: | awk '{print $2}'`

   ## Checking POD images for Vulnerable

   for image in $images_array
   do
      HIGH=`klar "$image" 2>/dev/null | grep  High: | cut -f2 -d " "`
      if [ $image != "" ] && [ $HIGH > 0 ]; then
        MSG="Image ($image) in POD ($POD) in Project ($NS) is a Vulnerable (High=$HIGH) image."
        echo "[ $DT ]  $MSG"
        echo "[ $DT ]  $MSG" >> $LOGPATH
        MSG1="Vulnerable image"
        notify
        ignore
        scaledown
        eliminate
      fi
   done

   ## Checking POD for Risky (mount service a/c,priviledge & risky rule)

   MOUNTPOD=`scan -psv -ns $NS 2>&1 | grep -s "+--------" -A 150 | grep "\s$POD\s"`
   RISKPOD=`scan -rp -ns $NS 2>&1 | grep -s "+--------" -A 150 | grep "\s$POD\s"`
   PRIVPOD=`scan -pp -ns $NS 2>&1 | grep -s "+--------" -A 150 | grep "\s$POD\s"`
   RROLE=`scan -aars "$SA" -k "ServiceAccount" -ns "$NS" 2>&1 | grep -s "+--------" -A 150 | grep $NS | awk '{print $6}'`
   DANPOD=`scan -rr -ns "$NS" 2>&1 | grep -s "+--------" -A 150 | grep $RROLE | grep $NS | awk '{ if($2 ~ /CRITICAL/ || $2 ~ /HIGH/) { system("echo DANGER-POD") } }'`

   if [ "$MOUNTPOD" != "" ] || [ "$RISKPOD" != "" ] || [ "$PRIVPOD" != "" ] || [ "$DANPOD" != "" ]; then
        MSG="POD ($POD) in project ($NS) has security risk."
        echo "[ $DT ]  $MSG"
        echo "[ $DT ]  $MSG" >> $LOGPATH
        echo "$PRIVPOD" >> $LOGPATH
        echo "$RISKPOD" >> $LOGPATH
        echo "$DANPOD" >> $LOGPATH
        echo "$MOUNTPOD" >> $LOGPATH
        MSG1="security risk"
        notify
        ignore
        scaledown
        eliminate
   fi

else
  exit
fi
