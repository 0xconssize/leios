#! /bin/bash

cardano-node run \
  --config leios/config.json \
  --topology leios/topology.json \
  --database-path leios/db \
  --socket-path leios/node.socket \
  --host-addr 0.0.0.0 \
  --port 3010 \
  --shelley-kes-key leios/keys/kes.skey \
  --shelley-vrf-key leios/keys/vrf.skey \
  --shelley-operational-certificate leios/keys/opcert.cert