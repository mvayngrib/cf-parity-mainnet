#!/bin/bash

set -x
set -euo pipefail

source scripts/.env

aws --profile "$AWS_PROFILE" cloudformation delete-stack --stack-name "$STACK_NAME"
aws --profile "$AWS_PROFILE" cloudformation wait stack-delete-complete --stack-name "$STACK_NAME"
./scripts/create-stack
