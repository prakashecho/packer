#!/bin/bash

# Source region where the AMI is located
SOURCE_REGION="us-east-1"

# Array of target regions to copy the AMI to
TARGET_REGIONS=("us-west-2" "eu-west-1" "ap-southeast-1")

# Array of AWS account IDs to share the AMI with
ACCOUNT_IDS=("280435798514")

# Function to wait for AMI to be available
wait_for_ami() {
  local region=$1
  local ami_id=$2
  echo "Waiting for AMI $ami_id in region $region to be available..."
  while [[ $(aws ec2 describe-images --image-ids "$ami_id" --region "$region" --query 'Images[0].State' --output text) != "available" ]]; do
    echo "AMI $ami_id in $region not yet available, waiting..."
    sleep 30  # Check every 30 seconds
  done
  echo "AMI $ami_id in $region is now available."
}

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

# Get the latest AMI ID from manifest.json
AMI_ID=$(jq -r '.builds[-1].artifact_id' manifest.json | cut -d ':' -f 2)
echo "Latest AMI ID: $AMI_ID"

# Wait for the source AMI to be available
wait_for_ami "$SOURCE_REGION" "$AMI_ID"

# Share the source AMI with each account
for account in "${ACCOUNT_IDS[@]}"; do
  share_ami "$SOURCE_REGION" "$account" "$AMI_ID"
done

# Copy AMI to target regions, wait for each, then share
for region in "${TARGET_REGIONS[@]}"; do
  echo "Copying AMI to region: $region"
  COPY_RESPONSE=$(aws ec2 copy-image \
    --source-image-id "$AMI_ID" \
    --source-region "$SOURCE_REGION" \
    --name "Jenkins-AMI-Copy-$region" \
    --region "$region" \
    --output json)
  
  # Extract the new AMI ID from the copy response
  TARGET_AMI_ID=$(echo "$COPY_RESPONSE" | jq -r '.ImageId')
  echo "New AMI ID in $region: $TARGET_AMI_ID"

  # Wait for the copied AMI to be available
  wait_for_ami "$region" "$TARGET_AMI_ID"

  # Share the copied AMI with each account
  for account in "${ACCOUNT_IDS[@]}"; do
    share_ami "$region" "$account" "$TARGET_AMI_ID"
  done
done

echo "AMI sharing process completed successfully."
