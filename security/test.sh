#!/bin/sh

EXTIME=`echo "$1" | jq  '.items [] .requestReceivedTimestamp'`
OCUSER=`echo "$1" |  jq  '.items [] .user.username' | sed 's/"//g'`
ACTION=`echo "$1" | jq  '.items [] .verb' | sed 's/"//g'`
CODE=`echo "$1" | jq  '.items [] .responseStatus.code'`
RESOURCE=`echo "$1" | jq  '.items [] .objectRef.resource' | sed 's/"//g'`
OBJNAME=`echo "$1" | jq  '.items [] .objectRef.name' | sed 's/"//g'`
MESSAGE=`echo "$1" | jq  '.items [] .responseStatus.message' | sed 's/"//g'`
STATUS=`echo "$1" | jq  '.items [] .responseStatus.status' | sed 's/"//g'`
SOURCEIP=`echo "$1" | jq  '.items [] .sourceIPs []' | sed 's/"//g'`
NS=`echo "$1" | jq  '.items [] .objectRef.namespace' | sed 's/"//g'`
REASON=`echo "$1" | jq  '.items [] .responseStatus.reason' | sed 's/"//g'`

##### for authentication #######

if [[ "$ACTION" == "post" && "$CODE" == "200" && "$OCUSER" == "null" ]]; then

   echo "Someone tried to login from this IP ($SOURCEIP) - Success"
   exit
fi

if [[ "$ACTION" == "get" && "$CODE" == "401" && "$OCUSER" == "null" ]]; then

   echo "Someone tried to login from this IP ($SOURCEIP) - $MESSAGE"
   exit
fi

##### for Resouces with create and delete verb #######

if [[ "$ACTION" == "create" || "$ACTION" == "delete" ]]; then

 if [[ "$RESOURCE" == "serviceaccount" || "$RESOURCE" == "secrets" || "$RESOURCE" == "configmaps" || "$RESOURCE" == "services" || "$RESOURCE" == "clusterroles" || "$RES
OURCE" == "clusterrolebindings" || "$RESOURCE" == "projectrequests" || "$RESOURCE" ==  "projects" ]]; then

   if [[ "$STATUS" == "Failure" ]]; then

        if [[ "$CODE" == "409" ]]; then

            echo "User ($OCUSER) tried to $ACTION $RESOURCE ($OBJNAME) in project ($NS) from this IP ($SOURCEIP) - $REASON"
            exit
        elif [[ "$CODE" == "404" ]]; then

            echo "User ($OCUSER) tried to $ACTION $RESOURCE ($OBJNAME) in project ($NS) from this IP ($SOURCEIP) - $REASON"
            exit

        elif [[ "$CODE" == "200" || "$CODE" == "201" ]]; then

            echo "User ($OCUSER) tried to $ACTION $RESOURCE ($OBJNAME) in project ($NS) from this IP ($SOURCEIP) - Success"
            exit

        fi

    elif [[ "$STATUS" != "Failure" ]]; then

        if [[ "$CODE" == "409" ]]; then

            echo "User ($OCUSER) tried to $ACTION $RESOURCE ($OBJNAME) in project ($NS) from this IP ($SOURCEIP) - $REASON"
            exit
        elif [[ "$CODE" == "404" ]]; then

            echo "User ($OCUSER) tried to $ACTION $RESOURCE ($OBJNAME) in project ($NS) from this IP ($SOURCEIP) - $REASON"
            exit

        elif [[ "$CODE" == "200" || "$CODE" == "201" ]]; then

            echo "User ($OCUSER) tried to $ACTION $RESOURCE ($OBJNAME) in project ($NS) from this IP ($SOURCEIP) - Success"
            exit

        fi
    fi
 fi

fi

######################################################
