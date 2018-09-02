#!/bin/bash

set -x
# set -euo pipefail

source scripts/env.sh

OUTPUTS=$(aws --profile "$AWS_PROFILE" cloudformation describe-stacks \
  --stack-name "$STACK_NAME" | jq -r .Stacks[].Outputs)

CLUSTER=$(echo $OUTPUTS | jq -r '.[] | select(.OutputKey=="ECSCluster").OutputValue')
SERVICE=$(echo $OUTPUTS | jq -r '.[] | select(.OutputKey=="EthECSService").OutputValue')

# TASK_DEFINITION_NAME=$(aws --profile "$AWS_PROFILE" ecs describe-services \
#   --services "$SERVICE" --cluster "$CLUSTER" \
#   | jq -r .services[0].taskDefinition)

# TASK_DEFINITION=$(aws --profile "$AWS_PROFILE" ecs describe-task-definition \
#   --task-def "$TASK_DEFINITION_NAME" | jq '.taskDefinition')

# NEW_CONTAINER_DEFINITIONS=$(echo "$TASK_DEFINITION" | jq --arg NEW_TAG $TAG_PURE 'def replace_tag: if . | test("[a-zA-Z0-9.]+/[a-zA-Z0-9]+:[a-zA-Z0-9]+") then sub("(?<s>[a-zA-Z0-9.]+/[a-zA-Z0-9]+:)[a-zA-Z0-9]+"; "\(.s)" + $NEW_TAG) else . end ; .containerDefinitions | [.[] | .+{image: .image | replace_tag}]')

# TASK_DEFINITION=$(echo "$TASK_DEFINITION" | jq ".+{containerDefinitions: $NEW_CONTAINER_DEFINITIONS}")

# # Default JQ filter for new task definition
# NEW_DEF_JQ_FILTER="family: .family, volumes: .volumes, containerDefinitions: .containerDefinitions"

# # Some options in task definition should only be included in new definition if present in
# # current definition. If found in current definition, append to JQ filter.
# CONDITIONAL_OPTIONS=(networkMode taskRoleArn)
# for i in "${CONDITIONAL_OPTIONS[@]}"; do
#   re=".*${i}.*"
#   if [[ "$TASK_DEFINITION" =~ $re ]]; then
#     NEW_DEF_JQ_FILTER="${NEW_DEF_JQ_FILTER}, ${i}: .${i}"
#   fi
# done

# # Build new DEF with jq filter
# NEW_DEF=$(echo $TASK_DEFINITION | jq "{${NEW_DEF_JQ_FILTER}}")
# NEW_TASKDEF=`aws ecs register-task-definition --cli-input-json "$NEW_DEF" | jq -r .taskDefinition.taskDefinitionArn`

# echo "New task definition registered, $NEW_TASKDEF"

aws --profile "$AWS_PROFILE" ecs update-service \
  --service "$SERVICE" \
  --cluster "$CLUSTER" \
  --force-new-deployment
