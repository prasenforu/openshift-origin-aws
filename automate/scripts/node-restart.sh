    #!/bin/sh
    #### Automation for node,docker,api,controller & host
    # Node restart script

    hst=$1
    alrn=$2
    stat=$3

    hstip=`echo $hst | cut -d ":" -f1`

    docstat=`ssh -o "StrictHostKeyChecking no" -i /etc/webhook/prasen.pem centos@$hstip "sudo systemctl is-active docker"`
    nodstat=`ssh -o "StrictHostKeyChecking no" -i /etc/webhook/prasen.pem centos@$hstip "sudo systemctl is-active origin-node"`

    if [ $stat == "firing" ]; then

    ### Checking OCP Node client

     if [ $nodstat == "inactive" ]; then
        ssh -o "StrictHostKeyChecking no" -i /etc/webhook/prasen.pem centos@$hstip "sudo systemctl start origin-node"
        sleep 7
     fi

    nodstat=`ssh -o "StrictHostKeyChecking no" -i /etc/webhook/prasen.pem centos@$hstip "sudo systemctl is-active origin-node"`

     if [ $nodstat == "active" ]; then
        echo "OCP Node Client is Running in Host : $1 "
     fi

    ### Checking OCP Docker client

     if [ $docstat == "inactive" ]; then
        ssh -o "StrictHostKeyChecking no" -i /etc/webhook/prasen.pem centos@$hstip "sudo systemctl start docker"
        sleep 7
     fi

    docstat=`ssh -o "StrictHostKeyChecking no" -i /etc/webhook/prasen.pem centos@$hstip "sudo systemctl is-active docker"`

     if [ $docstat == "active" ]; then
        echo "Docker is Running in Host : $1 "
     fi

    fi
