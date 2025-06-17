#!/bin/bash

AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-06776cce51381651f"
INSTANCES=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "frontend")
ZONE_ID="Z0193002ZK4VQFXB1ARL"
DOMAIN_NAME="prasad84s.site"

for instance in $@

    INSTANCES_ID=$(aws ec2 run-instance --image-id ami-09c813fb71547fc4f --instance-type t3.micro --security-group-ids sg-06776cce51381651f --tag-specification"ResourceType=instance,Tags=[{key=Name, value=test}]" --query "Instances[0].InstanceId" --output text)
    if [ $instance != "frontend" ]
    then
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCES_ID --query "Reservation[0].Instances[0].PrivateIpAddress" --output text)
        RECORD_NAME=$instance.$DOMAIN_NAME" 
    else
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCES_ID --query "Reservation[0].Instances[0].PrivateIpAddress" --output text
        RECORD_NAME="$DOMAIN_NAME" 
    fi
    echo "$instance IP address: $IP" 

    aws route53 change-resource-record-sets \
  --hosted-zone-id $ZONE_ID \
  --change-batch '
  {
    "Comment": "Creating or updating a record set for cognito endpoint"
    ,"Changes": [{
      "Action"              : "UPSERT"
      ,"ResourceRecordSet"  : {
        "Name"              : "'$RECORD_NAME'"
        ,"Type"             : "A"
        ,"TTL"              : 1
        ,"ResourceRecords"  : [{
            "Value"         : "'$IP'"
        }]
    }
    }]
}'
 
