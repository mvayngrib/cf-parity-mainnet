#!/bin/bash

# set -x
set -euo pipefail

source scripts/env.sh

aws cloudformation describe-stacks --stack-name "$STACK_NAME" \
  | jq -r '.Stacks[].Outputs[] | select(.OutputKey == "EthDNSName").OutputValue'
