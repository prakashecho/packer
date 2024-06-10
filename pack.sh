#!/bin/bash

# Specify the AMI ID directly
AMI_ID="ami-0427e1bc4e8737655"  # Replace with your actual AMI ID

# AWS accounts to share the AMI with (replace with actual account IDs)
ACCOUNTS=(
  "280435798514"
  )

# Share AMI with specified accounts
for account in "${ACCOUNTS[@]}"; do
  echo "Sharing AMI $AMI_ID with account $account..."
  aws ec2 modify-image-attribute \
    --image-id "$AMI_ID" \
    --launch-permission "Add=[{UserId=$account}]"
done

echo "AMI $AMI_ID has been shared with the specified accounts."
