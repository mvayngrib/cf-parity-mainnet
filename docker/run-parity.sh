#!/bin/bash
set -x
PUBLIC_IP=`curl -s http://169.254.169.254/latest/meta-data/public-ipv4`
PRIVATE_IP=`curl -s http://169.254.169.254/latest/meta-data/local-ipv4`
CHAIN=${1-mainnet}

/parity/parity --chain "$CHAIN" \
  --config config.toml \
  --nat extip:$PUBLIC_IP
