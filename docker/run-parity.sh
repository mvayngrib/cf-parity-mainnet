#!/bin/bash
set -x

# PRIVATE_IP=localhost
# BLOCK_ZERO_RESP="{\"result\":\"0x0\"}"

# poll() {
#   RESULT=$(curl -X POST -H 'Content-Type: application/json' \
#     --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":83}' \
#     "$PRIVATE_IP:8545" || echo "$BLOCK_ZERO_RESP")
#   BLOCK_HEX=$(echo $RESULT | jq .result -r)
#   echo $(( 16#${BLOCK_HEX#0x} ))
# }

# exit_on_sync() {
#   echo "WILL EXIT AFTER SYNCING TO BLOCK $1"
#   while true
#   do
#     CURRENT_BLOCK=$(poll)
#     echo "CURRENT BLOCK: $CURRENT_BLOCK"
#     if [ "$CURRENT_BLOCK" == "$1" ];
#     then
#       echo "SYNC COMPLETE!"
#       break
#     fi

#     sleep 30 # seconds
#   done
#   exit 0
# }

# if [ "$EXIT_AFTER_SYNC" == "1" ];
# then
#   exit_on_sync $TARGET_BLOCK
# fi

PUBLIC_IP=`curl -s http://169.254.169.254/latest/meta-data/public-ipv4`
PRIVATE_IP=`curl -s http://169.254.169.254/latest/meta-data/local-ipv4`

/parity/parity --config config.toml --nat extip:$PUBLIC_IP
