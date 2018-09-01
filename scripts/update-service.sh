#!/bin/bash

set -x
# set -euo pipefail

source scripts/.env

OUTPUTS=$(aws --profile "$AWS_PROFILE" cloudformation describe-stacks \
  --stack-name "$STACK_NAME" | jq -r .Stacks[].Outputs)

CLUSTER=$(echo $OUTPUTS | jq -r '.[] | select(.OutputKey=="ECSCluster").OutputValue')
SERVICE=$(echo $OUTPUTS | jq -r '.[] | select(.OutputKey=="EthECSCluster").OutputValue')

# ECS_STACK=$(aws --profile "$AWS_PROFILE" cloudformation describe-stack-resources \
#   --stack-name "$STACK_NAME" | jq -r '.StackResources[] | select(.LogicalResourceId=="ECS").PhysicalResourceId')

# ETH_STACK=$(aws --profile "$AWS_PROFILE" cloudformation describe-stack-resources \
#   --stack-name "$STACK_NAME" | jq -r '.StackResources[] | select(.LogicalResourceId=="Ethereum").PhysicalResourceId')

# CLUSTER=$(aws --profile "$AWS_PROFILE" cloudformation describe-stack-resources \
#   --stack-name "$ECS_STACK" | jq -r '.StackResources[] | select(.LogicalResourceId=="ECSCluster")'

aws --profile "$AWS_PROFILE" ecs update-service \
  --service "$SERVICE" \
  --cluster "$CLUSTER" \
  --force-new-deployment

