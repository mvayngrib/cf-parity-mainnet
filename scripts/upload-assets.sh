#!/bin/bash

set -x
# set -euo pipefail

source scripts/env.sh

CUR_DIR=$(pwd)
cd ./service && zip -r "$CUR_DIR/lambda.zip" . && cd "$CUR_DIR"
aws s3 cp lambda.zip "s3://$BUCKET/$STACK_NAME/"
aws s3 cp \
  --recursive "$CUR_DIR/cloudformation/" "s3://$BUCKET/$STACK_NAME/" \
  --exclude "*" \
  --include "*.yml"
