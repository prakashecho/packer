#!/bin/bash

AMI_ID=$(jq -r '.builds[-1].artifact_id' manifest.json | cut -d ':' -f 2)

aws ec2 copy-image \
  --source-image-id $AMI_ID \
  --source-region us-east-1 \
  --name "Jenkins-AMI-Copy" \
  --region us-west-2

aws ec2 modify-image-attribute \
  --image-id $AMI_ID \
  --launch-permission "Add=[{UserId=280435798514}]" \
  --region us-east-1
