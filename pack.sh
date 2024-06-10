#!/bin/bash

# Source region where the existing AMI is located
SOURCE_REGION="us-east-1"

# Existing AMI ID to be shared
EXISTING_AMI_ID="ami-0427e1bc4e8737655"  # Replace 'ami-xxxxxx' with your existing AMI ID

# Array of target regions to copy the AMI to
TARGET_REGIONS=("us-west-2" "eu-west-1" "ap-southeast-1")

# Array of AWS account IDs to share the AMI with
ACCOUNT_IDS=("280435798514")

# Function to share AMI with a specific account in a given region
share_ami() {
  local region=$1
  local account=$2
  local ami_id=$3
  echo "Sharing AMI $ami_id with account: $account in region: $region"
  aws ec2 modify-image-attribute \
    --image-id "$ami_id" \
    --launch-permission "Add=[{UserId=$account}]" \
    --region "$region"
}

# Share the existing AMI with each account in each region
for region in "${TARGET_REGIONS[@]}"; do
  # Share the existing AMI with each account in the current region
  for account in "${ACCOUNT_IDS[@]}"; do
    share_ami "$region" "$account" "$EXISTING_AMI_ID"
  done
done

echo "AMI sharing process completed successfully."
