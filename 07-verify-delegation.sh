#! /bin/bash

# Capture your pool id (from the cold key) and stake address
POOL_ID=$(cardano-cli dijkstra stake-pool id --cold-verification-key-file leios/keys/cold.vkey --output-format hex)
STAKE_ADDR=$(cardano-cli dijkstra stake-address build --stake-verification-key-file leios/keys/stake.vkey)
echo "pool id: $POOL_ID"
echo "stake address: $STAKE_ADDR"

# Is the pool registered on-chain?
cardano-cli dijkstra query pool-state --stake-pool-id "$POOL_ID"

# Did the delegation take effect?
cardano-cli dijkstra query stake-address-info --address "$STAKE_ADDR"