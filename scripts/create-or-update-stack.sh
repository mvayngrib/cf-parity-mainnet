#!/bin/bash

set -x
set -euo pipefail

source scripts/.env

# relative to build-params.js script
PARAMS_FILE=${1-"../cloudformation/stack-parameters.json"}

./scripts/validate-templates.sh
./scripts/upload-assets.sh

PARAMETERS=$(node scripts/build-params.js "$PARAMS_FILE" "$BUCKET/$STACK_NAME")
CUR_DIR=$(pwd)

EXISTING_STACKS=$(aws --profile "$AWS_PROFILE" cloudformation describe-stacks \
  --stack-name "$STACK_NAME" || '{"Stacks": []}')

EXISTING_STACK=$(echo $EXISTING_STACKS |
  jq -r '[.Stacks[] | select(.StackStatus=="UPDATE_COMPLETE" or .StackStatus=="CREATE_COMPLETE" or .StackStatus=="UPDATE_ROLLBACK_COMPLETE")][0].StackId')

if [ "$EXISTING_STACK" == "" ] || [ "$EXISTING_STACK" == "null" ];
then
  echo 'creating stack!'
  aws cloudformation create-stack \
    --profile "$AWS_PROFILE" \
    --stack-name "$STACK_NAME" \
    --template-body "file://$CUR_DIR/cloudformation/main.yml" \
    --parameters "$PARAMETERS" \
    --capabilities CAPABILITY_NAMED_IAM \
    --disable-rollback \
    --timeout 120000
else
  echo "creating stack $STACK_NAME"
  aws cloudformation update-stack \
    --profile "$AWS_PROFILE" \
    --stack-name "$STACK_NAME" \
    --template-body "file://$CUR_DIR/cloudformation/main.yml" \
    --parameters "$PARAMETERS" \
    --capabilities CAPABILITY_NAMED_IAM
fi