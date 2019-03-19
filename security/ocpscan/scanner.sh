#!/bin/sh

LOGPATH=/log/output.log
DT=`date '+%d/%m/%Y %H:%M:%S'`

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
STAGE=`echo "$1" | jq  '.items [] .stage' | sed 's/"//g'`
SUBRESOURCE=`echo "$1" | jq  '.items [] .objectRef.subresource' | sed 's/"//g'`
REQUESTURI=`echo "$1" | jq  '.items [] .requestURI' | sed 's/"//g'`

#### For POD/container login ########

if [ "$ACTION" = "create" ] && [ "$CODE" = "101" ] && [ "$STAGE" = "ResponseStarted" ] && [ "$SUBRESOURCE" = "exec" ]; then

     echo "[ $DT ]  User ($OCUSER) tried to login $RESOURCE ($OBJNAME) in project ($NS) from this IP ($SOURCEIP)"
     echo "[ $DT ]  User ($OCUSER) tried to login $RESOURCE ($OBJNAME) in project ($NS) from this IP ($SOURCEIP)" >> $LOGPATH
     exit
fi

##### for authentication #######

if [ "$ACTION" = "post" ] && [ "$CODE" = "200" ]; then

   echo "[ $DT ]  Someone tried to login from this IP ($SOURCEIP) - Success"
   echo "[ $DT ]  Someone tried to login from this IP ($SOURCEIP) - Success" >> $LOGPATH
   exit
fi

if [ "$ACTION" = "get" ] && [ "$CODE" = "401" ] && [ "REASON" != "Unauthorized" ]; then

   echo "[ $DT ]  Someone tried to login from this IP ($SOURCEIP) - $MESSAGE"
   echo "[ $DT ]  Someone tried to login from this IP ($SOURCEIP) - $MESSAGE" >> $LOGPATH
   exit
fi

if [ "$ACTION" = "head" ] && [ "$CODE" = "302" ]; then

   echo "[ $DT ]  Someone tried to login from this IP ($SOURCEIP) - $REQUESTURI"
   echo "[ $DT ]  Someone tried to login from this IP ($SOURCEIP) - $REQUESTURI" >> $LOGPATH
   exit
fi

if [ "$ACTION" = "get" ] && [ "$CODE" = "200" ] && [ "$RESOURCE" = "users" ]; then

   echo "[ $DT ]  User ($OCUSER) tried to login from this IP ($SOURCEIP) - $REQUESTURI"
   echo "[ $DT ]  User ($OCUSER) tried to login from this IP ($SOURCEIP) - $REQUESTURI" >> $LOGPATH
   exit
fi

##### for Resouces with create, delete, patch & bind  verb #######

if [ "$ACTION" = "create" ] || [ "$ACTION" = "delete" ] || [ "$ACTION" = "patch" ] || [ "$ACTION" = "bind" ] || [ "$ACTION" = "update" ]; then

 if [ "$RESOURCE" = "configmaps" ] || [ "$RESOURCE" = "services" ] || [ "$RESOURCE" = "clusterroles" ] || [ "$RESOURCE" = "clusterrolebindings" ] || [ "$RESOURCE" = "projectrequests" ] || [ "$RESOURCE" =  "projects" ] || [ "$RESOURCE" =  "rolebindings" ] || [ "$RESOURCE" = "securitycontextconstraints" ]; then

   if [ "$STATUS" = "Failure" ]; then

        if [ "$CODE" = "409" ]; then

            echo "[ $DT ]  User ($OCUSER) tried to $ACTION $RESOURCE ($OBJNAME) in project ($NS) from this IP ($SOURCEIP) - $REASON"
            echo "[ $DT ]  User ($OCUSER) tried to $ACTION $RESOURCE ($OBJNAME) in project ($NS) from this IP ($SOURCEIP) - $REASON" >> $LOGPATH
            exit
        elif [ "$CODE" = "404" ]; then

            echo "[ $DT ]  User ($OCUSER) tried to $ACTION $RESOURCE ($OBJNAME) in project ($NS) from this IP ($SOURCEIP) - $REASON"
            echo "[ $DT ]  User ($OCUSER) tried to $ACTION $RESOURCE ($OBJNAME) in project ($NS) from this IP ($SOURCEIP) - $REASON" >> $LOGPATH
            exit

        elif [ "$CODE" = "200" ] || [ "$CODE" = "201" ]; then

            echo "[ $DT ]  User ($OCUSER) tried to $ACTION $RESOURCE ($OBJNAME) in project ($NS) from this IP ($SOURCEIP) - Success"
            echo "[ $DT ]  User ($OCUSER) tried to $ACTION $RESOURCE ($OBJNAME) in project ($NS) from this IP ($SOURCEIP) - Success" >> $LOGPATH
            exit

        fi

    elif [ "$STATUS" != "Failure" ]; then

        if [ "$CODE" = "409" ]; then

            echo "[ $DT ]  User ($OCUSER) tried to $ACTION $RESOURCE ($OBJNAME) in project ($NS) from this IP ($SOURCEIP) - $REASON"
            echo "[ $DT ]  User ($OCUSER) tried to $ACTION $RESOURCE ($OBJNAME) in project ($NS) from this IP ($SOURCEIP) - $REASON" >> $LOGPATH
            exit

        elif [ "$CODE" = "404" ]; then

            echo "[ $DT ]  User ($OCUSER) tried to $ACTION $RESOURCE ($OBJNAME) in project ($NS) from this IP ($SOURCEIP) - $REASON"
            echo "[ $DT ]  User ($OCUSER) tried to $ACTION $RESOURCE ($OBJNAME) in project ($NS) from this IP ($SOURCEIP) - $REASON" >> $LOGPATH
            exit

        elif [ "$CODE" = "200" ] || [ "$CODE" = "201" ]; then

            echo "[ $DT ]  User ($OCUSER) tried to $ACTION $RESOURCE ($OBJNAME) in project ($NS) from this IP ($SOURCEIP) - Success"
            echo "[ $DT ]  User ($OCUSER) tried to $ACTION $RESOURCE ($OBJNAME) in project ($NS) from this IP ($SOURCEIP) - Success" >> $LOGPATH
            exit

        fi
    fi
 fi

fi

##### For Resouces (secrets) with create, delete, patch, list & get  verb #######

if [ "$ACTION" = "create" ] || [ "$ACTION" = "delete" ] || [ "$ACTION" = "patch" ] || [ "$ACTION" = "update" ] || [ "$ACTION" = "get" ] || [ "$ACTION" = "list" ]; then

  if [ "$RESOURCE" = "secrets" ] || [ "$RESOURCE" = "serviceaccounts" ]; then

     if [ "$STATUS" = "Failure" ]; then

        if [ "$CODE" = "409" ]; then

            echo "[ $DT ]  User ($OCUSER) tried to $ACTION $RESOURCE ($OBJNAME) in project ($NS) from this IP ($SOURCEIP) - $REASON"
            echo "[ $DT ]  User ($OCUSER) tried to $ACTION $RESOURCE ($OBJNAME) in project ($NS) from this IP ($SOURCEIP) - $REASON" >> $LOGPATH
            exit
        elif [ "$CODE" = "404" ]; then

            echo "[ $DT ]  User ($OCUSER) tried to $ACTION $RESOURCE ($OBJNAME) in project ($NS) from this IP ($SOURCEIP) - $REASON"
            echo "[ $DT ]  User ($OCUSER) tried to $ACTION $RESOURCE ($OBJNAME) in project ($NS) from this IP ($SOURCEIP) - $REASON" >> $LOGPATH
            exit

        elif [ "$CODE" = "200" ] || [ "$CODE" = "201" ]; then

            echo "[ $DT ]  User ($OCUSER) tried to $ACTION $RESOURCE ($OBJNAME) in project ($NS) from this IP ($SOURCEIP) - Success"
            echo "[ $DT ]  User ($OCUSER) tried to $ACTION $RESOURCE ($OBJNAME) in project ($NS) from this IP ($SOURCEIP) - Success" >> $LOGPATH
            exit

        fi

     elif [ "$STATUS" != "Failure" ]; then

        if [ "$CODE" = "409" ]; then

            echo "[ $DT ]  User ($OCUSER) tried to $ACTION $RESOURCE ($OBJNAME) in project ($NS) from this IP ($SOURCEIP) - $REASON"
            echo "[ $DT ]  User ($OCUSER) tried to $ACTION $RESOURCE ($OBJNAME) in project ($NS) from this IP ($SOURCEIP) - $REASON" >> $LOGPATH
            exit

        elif [ "$CODE" = "404" ]; then

            echo "[ $DT ]  User ($OCUSER) tried to $ACTION $RESOURCE ($OBJNAME) in project ($NS) from this IP ($SOURCEIP) - $REASON"
            echo "[ $DT ]  User ($OCUSER) tried to $ACTION $RESOURCE ($OBJNAME) in project ($NS) from this IP ($SOURCEIP) - $REASON" >> $LOGPATH
            exit

        elif [ "$CODE" = "200" ] || [ "$CODE" = "201" ]; then

            echo "[ $DT ]  User ($OCUSER) tried to $ACTION $RESOURCE ($OBJNAME) in project ($NS) from this IP ($SOURCEIP) - Success"
            echo "[ $DT ]  User ($OCUSER) tried to $ACTION $RESOURCE ($OBJNAME) in project ($NS) from this IP ($SOURCEIP) - Success" >> $LOGPATH
            exit

        fi
     fi
  fi
fi

######################################################
