#! /bin/bash

cd tmp-testnet

cardano-node run \
  --config config.json \
  --topology topology.json \
  --database-path db \
  --socket-path node.socket \
  --host-addr 0.0.0.0 \
  --port 3010 \
  --shelley-kes-key ../leios/keys/kes.skey \
  --shelley-vrf-key ../leios/keys/vrf.skey \
  --shelley-operational-certificate ../leios/keys/opcert.cert