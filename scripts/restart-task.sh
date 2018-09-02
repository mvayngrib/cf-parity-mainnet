#!/bin/bash

set -x
set -euo pipefail

source scripts/env.sh

cf() {
  aws --profile "$AWS_PROFILE" cloudformation $@
}

ecs() {
  aws --profile "$AWS_PROFILE" ecs $@
}

OUTPUTS=$(cf describe-stacks --stack-name "$STACK_NAME" | jq -r .Stacks[].Outputs)

CLUSTER=$(echo $OUTPUTS | jq -r '.[] | select(.OutputKey=="ECSCluster").OutputValue')
SERVICE=$(echo $OUTPUTS | jq -r '.[] | select(.OutputKey=="EthECSService").OutputValue')

TASK_DEFINITION_NAME=$(ecs describe-services --services "$SERVICE" --cluster "$CLUSTER" \
  | jq -r .services[0].taskDefinition)

TASK_DEFINITION=$(ecs describe-task-definition \
  --task-def "$TASK_DEFINITION_NAME" | jq '.taskDefinition')

TASKS=$(ecs list-tasks --service-name "$SERVICE" --cluster $CLUSTER | jq -r .taskArns[])

for t in $TASKS;
do
  ecs stop-task --task "$t" --cluster "$CLUSTER"
done

./scripts/update-service.sh
