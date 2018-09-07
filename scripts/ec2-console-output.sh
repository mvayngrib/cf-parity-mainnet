#!/bin/bash

set -euo pipefail
set -x

EC2_INSTANCE=$(./scripts/get-container-instance.sh)
aws ec2 get-console-output --instance-id "$EC2_INSTANCE"
