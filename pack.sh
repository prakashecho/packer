#!/bin/bash

# Read the AMI ID from the manifest file
SOURCE_AMI_ID=$(jq -r '.builds[0].artifact_id' manifest.json | cut -d ':' -f2)

# AWS accounts to share the AMI with (replace with actual account IDs)
ACCOUNTS=(
  "280435798514"
  
)

# Specific regions to share the AMI
REGIONS=(
  "us-east-2"
  "us-west-2"
)

# Function to wait for AMI to be available
wait_for_ami() {
  local ami_id=$1
  local region=$2
  while true; do
    ami_state=$(aws ec2 describe-images --image-ids "$ami_id" --region "$region" --query 'Images[0].State' --output text)
    if [ "$ami_state" == "available" ]; then
      break
    fi
    echo "Waiting for AMI $ami_id in region $region to be available..."
    sleep 10
  done
}

# Copy AMI to specified regions
for region in "${REGIONS[@]}"; do
  echo "Copying AMI to region: $region"
  REGIONAL_AMI_ID=$(aws ec2 copy-image --source-image-id "$SOURCE_AMI_ID" --source-region "us-east-1" --region "$region" --name "Jenkins-AMI-$region" --output text)
  echo "AMI ID in $region: $REGIONAL_AMI_ID"

  # Wait for the AMI to be available before sharing
  wait_for_ami "$REGIONAL_AMI_ID" "$region"

  # Share AMI with specified accounts
  for account in "${ACCOUNTS[@]}"; do
    echo "Sharing AMI $REGIONAL_AMI_ID in region $region with account $account..."
    aws ec2 modify-image-attribute \
      --image-id "$REGIONAL_AMI_ID" \
      --launch-permission "Add=[{UserId=$account}]" \
      --region "$region"
  done
done

echo "AMIs have been copied to specified regions and shared with the specified accounts."
