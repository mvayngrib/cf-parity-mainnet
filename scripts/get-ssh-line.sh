#!/bin/bash

set -x
# set -euo pipefail

source scripts/env.sh

# aws cloudformation describe-stacks --stack-name "$STACK_NAME" \
#   | jq -r '[.Stacks[].Resources[] | select(.LogicalId == "DataVolume1" or .LogicalId == "DataVolume2")]'

SSH_KEY_PATH="$1"
BASTION=$(aws cloudformation describe-stacks --stack-name "$STACK_NAME" \
  | jq -r '.Stacks[].Outputs[] | select(.OutputKey == "BastionPublicIP").OutputValue')

TARGET=$(./scripts/get-container-instance-ip.sh)

if [ -n "$SSH_KEY_PATH" ];
then
  LINE="ssh -i $1 -t ec2-user@$BASTION ssh ec2-user@$TARGET"
else
  LINE="ssh -t ec2-user@$BASTION ssh ec2-user@$TARGET"
fi

#echo "NOTE: make sure you copy your ssh key to the bastion host: $BASTION"
echo "$LINE"
