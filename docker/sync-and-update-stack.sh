#!/bin/bash
set -x
set -euo pipefail

LOCAL_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
AWS_INSTANCE_ID=$(curl http://169.254.169.254/latest/meta-data/instance-id)
ROOT_DISK_ID=$(aws ec2 describe-volumes --filter "Name=attachment.instance-id, Values=$AWS_INSTANCE_ID" --query "Volumes[].VolumeId" --out text)
BLOCK_ZERO_RESP='{"result":"0x0"}'

poll() {
  RESULT=$(curl -X POST -H 'Content-Type: application/json' \
    --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":83}' \
    "$LOCAL_IP:8545" || echo "$BLOCK_ZERO_RESP")
  BLOCK_HEX=$(echo $RESULT | jq .result -r)
  echo $(( 16#${BLOCK_HEX#0x} ))
}

sync_to_block() {
  echo "WILL EXIT AFTER SYNCING TO BLOCK $1"
  while true
  do
    CURRENT_BLOCK=$(poll)
    echo "CURRENT BLOCK: $CURRENT_BLOCK"
    if [ "$CURRENT_BLOCK" == "$1" ];
    then
      echo "SYNC COMPLETE!"
      break
    fi

    sleep 30 # seconds
  done
}

get_volume_id() {
  AWS_INSTANCE_ID=$(curl )
}

get_update_stack_params() {
  echo "taking snapshot of EBS volume: $ROOT_DISK_ID"
  SNAPSHOT_ID=$(aws ec2 create-snapshot \
    --volume-id "$ROOT_DISK_ID" \
    --description "ethereum blockchain synced up to block $TARGET_BLOCK" \
    | jq -r .SnapshotId)

  echo "waiting for snapshot to finish: $SNAPSHOT_ID"
  aws ec2 wait snapshot-completed --filters "Name=snapshot-id, Values=$SNAPSHOT_ID"

  PARAMETERS=$(aws cloudformation describe-stacks --region $REGION --stack-name "$STACK_NAME" |
    jq '[.Stacks[] | select(.StackStatus=="UPDATE_COMPLETE" or .StackStatus=="CREATE_COMPLETE")][0].Parameters')

  CURRENT_SNAPSHOT=$(echo "$PARAMETERS" | jq '.[] | select(.ParameterKey == "ChainSnapshotId")')
  if [ $(echo $CURRENT_SNAPSHOT | wc -c) == "0" ]
  then
    PARAMETERS=$(echo $PARAMETERS | jq ".[.|length] |= . + {\"ParameterKey\":\"ChainSnapshotId\",\"ParameterValue\":\"$SNAPSHOT_ID\"}")
  else
    PARAMETERS=$(echo $PARAMETERS | jq "[.[] | select(.ParameterKey == \"ChainSnapshotId\").ParameterValue = \"$SNAPSHOT_ID\"]")
  fi

  echo "$PARAMETERS"
}

sync_and_update_stack() {
  sync_to_block "$1"
  PARAMETERS=$(get_update_stack_params)
  echo "updating stack with parameters: $PARAMETERS"
  aws cloudformation update-stack \
    --region "$REGION" \
    --stack-name "$STACK_NAME" \
    --parameters "$PARAMETERS" \
    --use-previous-template \
    --capabilities CAPABILITY_NAMED_IAM
}

REGION=${AWS::Region}
STACK_NAME=${AWS::StackId}
sync_and_update_stack $TARGET_BLOCK
