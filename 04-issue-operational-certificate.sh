#! /bin/bash

if [ -f leios/keys/opcert.cert ]; then
  echo "Operational certificate already exists. Do you want to overwrite it? (y/n)"
  read answer
  if [ "$answer" != "y" ]; then
    echo "Exiting."
    exit 0
  fi
fi

slotsPerKESPeriod=$(jq -r '.slotsPerKESPeriod' tmp-testnet/shelley-genesis.json)
slotNo=$(cardano-cli query tip | jq -r '.slot')
kesPeriod=$(( slotNo / slotsPerKESPeriod ))

cardano-cli dijkstra node issue-op-cert \
  --kes-verification-key-file leios/keys/kes.vkey \
  --cold-signing-key-file leios/keys/cold.skey \
  --operational-certificate-issue-counter-file leios/keys/opcert.counter \
  --kes-period "$kesPeriod" \
  --out-file leios/keys/opcert.cert