#!/bin/bash

set -euo pipefail
set -x

source scripts/env.sh

EC2_INSTANCE=$(./scripts/get-container-instance.sh)

IP=$(aws ec2 describe-instances --instance-ids $EC2_INSTANCE | jq -r '.Reservations[].Instances[].PrivateIpAddress')

echo $IP
