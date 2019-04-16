#!/bin/sh

LOGPATH=/log/output.log
DT=`date '+%d/%m/%Y %H:%M:%S'`
MAILID="mailid@hotmail.com"

alias scan='sh /usr/bin/scan.sh'

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

####### MAIL FOR AUTHENTICATION #######

mailsendauth () {

if [ "$MAIL" = "y" ] || [ "$MAIL" = "Y" ]; then
        sed "s/MSG/$MSG/g" /etc/webhook/mailtemplate.txt > /etc/webhook/mailbody.txt
        /etc/webhook/mailsend.py "ALERT: Authentication concern from $SOURCEIP" "$MAILID"
        exit
else
        exit
fi
}

####### MAIL FOR RESOURCE #######

mailsendrest () {

if [ "$MAIL" = "y" ] || [ "$MAIL" = "Y" ]; then
        sed "s/MSG/$MSG/g" /etc/webhook/mailtemplate.txt > /etc/webhook/mailbody.txt
        /etc/webhook/mailsend.py "ALERT: Security issue on $RESOURCE ($OBJNAME)" "$MAILID"
        exit
else
        exit
fi
}

#### For POD/container ########

if [ "$RESOURCE" = "pods" ] && [ "$ACTION" = "create" ] && [ "$CODE" = "101" ] && [ "$STAGE" = "ResponseStarted" ] && [ "$SUBRESOURCE" = "exec" ]; then

     MSG="User ($OCUSER) tried to login $RESOURCE ($OBJNAME) in project ($NS) from this IP ($SOURCEIP)"
     echo "[ $DT ]  $MSG"
     echo "[ $DT ]  $MSG" >> $LOGPATH
     MAIL=y
     mailsendrest
fi

if [ "$RESOURCE" = "pods" ] && [ "$ACTION" = "create" ] && [ "$CODE" = "201" ] && [ "$STAGE" = "ResponseComplete" ]; then

     op=`scan -psv -ns $NS 2>&1 | grep -s "+--------" -A 150 | grep "\s$OBJNAME\s"`
     op1=`scan -rp -ns $NS 2>&1 | grep -s "+--------" -A 150 | grep "\s$OBJNAME\s"`
     op2=`scan -pp -ns $NS 2>&1 | grep -s "+--------" -A 150 | grep "\s$OBJNAME\s"`

     if [ "$op1" != "" ] || [ "$op2" != "" ] || [ "$op" != "" ]; then
        MSG="POD ($OBJNAME) in project ($NS) has receurity risk."
        echo "[ $DT ]  $MSG"
        echo "[ $DT ]  $MSG" >> $LOGPATH
        echo "$op1" >> $LOGPATH
        echo "$op2" >> $LOGPATH
        echo "$op" >> $LOGPATH
        MAIL=y
        mailsendrest
     fi
fi


##### for authentication #######

if [ "$ACTION" = "post" ] && [ "$CODE" = "200" ]; then

   MSG="Someone tried to login from this IP ($SOURCEIP) - Success"
   echo "[ $DT ]  $MSG"
   echo "[ $DT ]  $MSG" >> $LOGPATH
   MAIL=y
   mailsendauth
fi

if [ "$ACTION" = "get" ] && [ "$CODE" = "401" ] && [ "REASON" != "Unauthorized" ]; then

   MSG="Someone tried to login from this IP ($SOURCEIP) - $MESSAGE"
   echo "[ $DT ]  $MSG"
   echo "[ $DT ]  $MSG" >> $LOGPATH
   MAIL=y
   mailsendauth
fi

if [ "$ACTION" = "head" ] && [ "$CODE" = "302" ]; then

   MSG="Someone tried to login from this IP ($SOURCEIP) - $REQUESTURI"
   echo "[ $DT ]  $MSG"
   echo "[ $DT ]  $MSG" >> $LOGPATH
   MAIL=y
   mailsendauth
fi

if [ "$ACTION" = "post" ] && [ "$CODE" = "302" ]; then

   MSG="Someone tried to login from this IP ($SOURCEIP) - $REQUESTURI"
   echo "[ $DT ]  $MSG"
   echo "[ $DT ]  $MSG" >> $LOGPATH
   MAIL=y
   mailsendauth
fi

if [ "$ACTION" = "get" ] && [ "$CODE" = "200" ] && [ "$RESOURCE" = "users" ]; then

   MSG="User ($OCUSER) tried to login from this IP ($SOURCEIP) - $REQUESTURI"
   echo "[ $DT ]  $MSG"
   echo "[ $DT ]  $MSG" >> $LOGPATH
   MAIL=n
   mailsendauth
fi

##### for Resouces with create, delete, patch & bind  verb #######

if [ "$ACTION" = "create" ] || [ "$ACTION" = "delete" ] || [ "$ACTION" = "patch" ] || [ "$ACTION" = "bind" ] || [ "$ACTION" = "update" ]; then

 if [ "$RESOURCE" = "configmaps" ] || [ "$RESOURCE" = "services" ] || [ "$RESOURCE" = "clusterroles" ] || [ "$RESOURCE" = "clusterrolebindings" ] || [ "$RESOURCE" = "projectrequests" ] || [ "$RESOURCE" =  "projects" ] || [ "$RESOURCE" =  "rolebindings" ] || [ "$RESOURCE" = "securitycontextconstraints" ]; then

   if [ "$STATUS" = "Failure" ]; then

        if [ "$CODE" = "409" ]; then

            MSG="User ($OCUSER) tried to $ACTION $RESOURCE ($OBJNAME) in project ($NS) from this IP ($SOURCEIP) - $REASON"
            echo "[ $DT ]  $MSG"
            echo "[ $DT ]  $MSG" >> $LOGPATH
            MAIL=y
            mailsendrest
        elif [ "$CODE" = "404" ]; then

            MSG="User ($OCUSER) tried to $ACTION $RESOURCE ($OBJNAME) in project ($NS) from this IP ($SOURCEIP) - $REASON"
            echo "[ $DT ]  $MSG"
            echo "[ $DT ]  $MSG" >> $LOGPATH
            MAIL=y
            mailsendrest

        elif [ "$CODE" = "200" ] || [ "$CODE" = "201" ]; then

            MSG="User ($OCUSER) tried to $ACTION $RESOURCE ($OBJNAME) in project ($NS) from this IP ($SOURCEIP) - Success"
            echo "[ $DT ]  $MSG"
            echo "[ $DT ]  $MSG" >> $LOGPATH
            MAIL=y

            if [ "$RESOURCE" = "clusterrolebindings" ] && [ "$ACTION" = "create" ]; then
               scan -crru $OBJNAME 2>&1 | grep -s "+--------" -A 50 >> $LOGPATH
            fi
            if [ "$RESOURCE" = "clusterrolebindings" ] && [ "$ACTION" = "patch" ]; then
               scan -crru $OBJNAME 2>&1 | grep -s "+--------" -A 50 >> $LOGPATH
            fi
            if [ "$RESOURCE" = "clusterroles" ] && [ "$ACTION" = "patch" ]; then
               op=`scan -aarbcr $OBJNAME 2>&1 | grep -v Associated | grep RoleBinding | cut -d "|" -f3`
               scan -crru $op 2>&1 | grep -s "+--------" -A 50 >> $LOGPATH
            fi

            mailsendrest
        fi

    elif [ "$STATUS" != "Failure" ]; then

        if [ "$CODE" = "409" ]; then

            MSG="User ($OCUSER) tried to $ACTION $RESOURCE ($OBJNAME) in project ($NS) from this IP ($SOURCEIP) - $REASON"
            echo "[ $DT ]  $MSG"
            echo "[ $DT ]  $MSG" >> $LOGPATH
            MAIL=y
            mailsendrest

        elif [ "$CODE" = "404" ]; then

            MSG="User ($OCUSER) tried to $ACTION $RESOURCE ($OBJNAME) in project ($NS) from this IP ($SOURCEIP) - $REASON"
            echo "[ $DT ]  $MSG"
            echo "[ $DT ]  $MSG" >> $LOGPATH
            MAIL=y
            mailsendrest

        elif [ "$CODE" = "200" ] || [ "$CODE" = "201" ]; then

            MSG="User ($OCUSER) tried to $ACTION $RESOURCE ($OBJNAME) in project ($NS) from this IP ($SOURCEIP) - Success"
            echo "[ $DT ]  $MSG"
            echo "[ $DT ]  $MSG" >> $LOGPATH
            MAIL=y

            if [ "$RESOURCE" = "clusterrolebindings" ] && [ "$ACTION" = "create" ]; then
               scan -crru $OBJNAME 2>&1 | grep -s "+--------" -A 50 >> $LOGPATH
            fi
            if [ "$RESOURCE" = "clusterrolebindings" ] && [ "$ACTION" = "patch" ]; then
               scan -crru $OBJNAME 2>&1 | grep -s "+--------" -A 50 >> $LOGPATH
            fi
            if [ "$RESOURCE" = "clusterroles" ] && [ "$ACTION" = "patch" ]; then
               op=`scan -aarbcr $OBJNAME 2>&1 | grep -v Associated | grep RoleBinding | cut -d "|" -f3`
               scan -crru $op 2>&1 | grep -s "+--------" -A 50 >> $LOGPATH
            fi

            mailsendrest
        fi
    fi
 fi

fi

##### For Resouces (secrets) with create, delete, patch, list & get  verb #######

if [ "$ACTION" = "create" ] || [ "$ACTION" = "delete" ] || [ "$ACTION" = "patch" ] || [ "$ACTION" = "update" ] || [ "$ACTION" = "get" ] || [ "$ACTION" = "list" ]; then

  if [ "$RESOURCE" = "secrets" ] || [ "$RESOURCE" = "serviceaccounts" ]; then

     if [ "$STATUS" = "Failure" ]; then

        if [ "$CODE" = "409" ]; then

            MSG="User ($OCUSER) tried to $ACTION $RESOURCE ($OBJNAME) in project ($NS) from this IP ($SOURCEIP) - $REASON"
            echo "[ $DT ]  $MSG"
            echo "[ $DT ]  $MSG" >> $LOGPATH
            MAIL=y
            mailsendrest

        elif [ "$CODE" = "404" ]; then

            MSG="User ($OCUSER) tried to $ACTION $RESOURCE ($OBJNAME) in project ($NS) from this IP ($SOURCEIP) - $REASON"
            echo "[ $DT ]  $MSG"
            echo "[ $DT ]  $MSG" >> $LOGPATH
            MAIL=y
            mailsendrest

        elif [ "$CODE" = "200" ] || [ "$CODE" = "201" ]; then

            MSG="User ($OCUSER) tried to $ACTION $RESOURCE ($OBJNAME) in project ($NS) from this IP ($SOURCEIP) - Success"
            echo "[ $DT ]  $MSG"
            echo "[ $DT ]  $MSG" >> $LOGPATH
            MAIL=y
            mailsendrest
        fi

     elif [ "$STATUS" != "Failure" ]; then

        if [ "$CODE" = "409" ]; then

            MSG="User ($OCUSER) tried to $ACTION $RESOURCE ($OBJNAME) in project ($NS) from this IP ($SOURCEIP) - $REASON"
            echo "[ $DT ]  $MSG"
            echo "[ $DT ]  $MSG" >> $LOGPATH
            MAIL=y
            mailsendrest

        elif [ "$CODE" = "404" ]; then

            MSG="User ($OCUSER) tried to $ACTION $RESOURCE ($OBJNAME) in project ($NS) from this IP ($SOURCEIP) - $REASON"
            echo "[ $DT ]  $MSG"
            echo "[ $DT ]  $MSG" >> $LOGPATH
            MAIL=y
            mailsendrest

        elif [ "$CODE" = "200" ] || [ "$CODE" = "201" ]; then

            MSG="User ($OCUSER) tried to $ACTION $RESOURCE ($OBJNAME) in project ($NS) from this IP ($SOURCEIP) - Success"
            echo "[ $DT ]  $MSG"
            echo "[ $DT ]  $MSG" >> $LOGPATH
            MAIL=y
            mailsendrest
        fi
     fi
  fi
fi

###############################
