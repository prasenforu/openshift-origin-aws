#!/bin/sh

## Scripts for autoscale

# KUBE Authentication

POD=`oc get pod -n $1 | grep $2 | awk '{print $1}' | head -n 1`
REP=`oc describe pod $POD -n $1 | grep "Controlled By:" | awk '{print $3}'`
DEP=`oc describe $REP -n $1 | grep "Controlled By:" | awk '{print $3}'`

echo "Application ($2) status of Project ($1) before scale up/down"
oc get $REP -n $1
oc get $DEP -n $1

# DESIRED value of deploy/apps

de=`oc get $REP -n $1 | awk '{print $2}' | grep -v DESIRED`

# CURRENT value of deploy/apps

cu=`oc get $REP -n $1 | awk '{print $3}' | grep -v CURRENT`

# Checking for POD  status addition for firing and substaraction for resolved
# If CURRENT & DESIRED value same and below one (1) then it will exit

if [ $3 == "firing" ]; then
   pm='+'
   dpm=scale-up
fi

if [ $3 == "resolved" ]; then
   if [ $de = $cu ] && [ $de -gt 1 ] && [ $cu -gt 1 ]; then
      pm='-'
      dpm=scale-down
   else
      echo "Looks like CURRENT & DESIRED value NOT same or below one (1)"
      oc get $REP -n $1
      oc get $DEP -n $1
      exit
   fi
fi

# IF CURRENT value & DESIRED value same then decrease one pod

if [ $de = $cu ]; then
   de=$((de $pm 1))
   oc scale $DEP --replicas=$de -n $1
else
   echo "Looks like CURRENT & DESIRED value NOT same."
   oc get $REP -n $1
   oc get $DEP -n $1
   exit
fi

# Status
echo "Application ($2) of Project ($1) going to $dpm"

oc get $REP -n $1
oc get $DEP -n $1
