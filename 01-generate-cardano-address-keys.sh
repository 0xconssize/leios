#! /bin/bash

if [ -d leios/keys ]; then
  echo "Keys already exist. Remove the leios/keys directory to generate new keys."
  exit 1
fi

mkdir -p leios/keys

# Payment key pair (holds funds)
cardano-cli dijkstra address key-gen \
  --verification-key-file leios/keys/payment.vkey \
  --signing-key-file leios/keys/payment.skey

# Stake key pair (controls delegation)
cardano-cli dijkstra stake-address key-gen \
  --verification-key-file leios/keys/stake.vkey \
  --signing-key-file leios/keys/stake.skey

cardano-cli dijkstra address build \
  --payment-verification-key-file leios/keys/payment.vkey \
  --stake-verification-key-file leios/keys/stake.vkey \
  --out-file leios/keys/payment.addr

echo "Payment address:"
cat leios/keys/payment.addr