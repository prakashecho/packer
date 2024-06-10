#!/bin/bash

# Get the latest AMI ID
AMI_ID=$(jq -r '.builds[-1].artifact_id' manifest.json | cut -d ':' -f 2)

# Source region where the AMI is located
SOURCE_REGION="us-east-1"

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

# Copy AMI to target regions
for region in "${TARGET_REGIONS[@]}"; do
  echo "Copying AMI to region: $region"
  aws ec2 copy-image \
    --source-image-id "$AMI_ID" \
    --source-region "$SOURCE_REGION" \
    --name "Jenkins-AMI-Copy-$region" \
    --region "$region"
done

# Wait for AMIs to be available in all regions
echo "Waiting for AMIs to be available in all regions..."
sleep 60  # Adjust this value based on how long it typically takes for your AMIs to be available

# Share AMI with each account in all regions
for account in "${ACCOUNT_IDS[@]}"; do
  # Share in source region
  share_ami "$SOURCE_REGION" "$account" "$AMI_ID"

  # Share in target regions
  for region in "${TARGET_REGIONS[@]}"; do
    # Get the AMI ID in the target region
    TARGET_AMI_ID=$(aws ec2 describe-images \
      --filters "Name=name,Values=Jenkins-AMI-Copy-$region" \
      --query 'Images[0].ImageId' \
      --output text \
      --region "$region")

    # Share the AMI in the target region
    share_ami "$region" "$account" "$TARGET_AMI_ID"
  done
done
