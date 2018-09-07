#!/bin/bash

set -euo pipefail
set -x

source scripts/env.sh

OUTPUTS=$(aws --profile "$AWS_PROFILE" cloudformation describe-stacks \
  --stack-name "$STACK_NAME" | jq -r .Stacks[].Outputs)

CLUSTER=$(echo $OUTPUTS | jq -r '.[] | select(.OutputKey=="ECSCluster").OutputValue')
CONTAINER_INSTANCE=$(aws --profile "$AWS_PROFILE" ecs list-container-instances --cluster "$CLUSTER" \
  | jq -r '.containerInstanceArns[0]')

EC2_INSTANCE=$(aws --profile "$AWS_PROFILE" ecs describe-container-instances \
  --cluster "$CLUSTER" \
  --container-instances "$CONTAINER_INSTANCE" \
  | jq -r '.containerInstances[0].ec2InstanceId')

echo "$EC2_INSTANCE"
