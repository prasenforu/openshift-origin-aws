#!/bin/bash

# This script will install AWS CLI tool

# Create by Prasenjit Kar (prasenforu@hotmail.com)
# Version 0.1

# Check AWS CLI installed or not
# If not installed it will start download and install

if ! type "aws" > /dev/null; then
    echo "Installing AWS ..."
    echo "Downloading AWS CLI package and unzip"
        wget https://s3.amazonaws.com/aws-cli/awscli-bundle.zip
        unzip awscli-bundle.zip
sudo ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws
    echo "Execute below command with root priviledge in different terminal"
    echo ""
    echo ""
    echo ""
    echo "sudo ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws"
    echo ""
    echo ""
    echo "Create Security file in your user ID"
        mkdir ~/.aws
        touch ~/.aws/config
cat <<EOF > ~/.aws/config
[default]
aws_access_key_id=< PUT YOUR ACCESS KEY >
aws_secret_access_key=< PUT YOUR SECRET ACCESS KEY >
region=ap-southeast-2
output=text
EOF
else
    echo "AWS CLI is already Installed."
fi

