#! /bin/bash

cardano-cli dijkstra stake-address registration-certificate \
  --stake-verification-key-file leios/keys/stake.vkey \
  --key-reg-deposit-amt "$(cardano-cli dijkstra query gov-state | jq .currentPParams.stakeAddressDeposit)" \
  --out-file leios/keys/stake-reg.cert

echo "Enter your public IP address for the block producer node:"
read block_producer_ip


cardano-cli dijkstra stake-pool registration-certificate \
  --cold-verification-key-file leios/keys/cold.vkey \
  --vrf-verification-key-file leios/keys/vrf.vkey \
  --pool-pledge 1000000000 \
  --pool-cost 170000000 \
  --pool-margin 0.05 \
  --pool-reward-account-verification-key-file leios/keys/stake.vkey \
  --pool-owner-stake-verification-key-file leios/keys/stake.vkey \
  --pool-relay-ipv4 "$block_producer_ip" \
  --pool-relay-port 3010 \
  --out-file leios/keys/pool-reg.cert

UTXO=$(cardano-cli dijkstra query utxo --address "$(cat leios/keys/payment.addr)")
TXIN=$(echo "$UTXO" | jq -r 'keys[0]')
FUNDS=$(echo "$UTXO" | jq -r '.[keys[0]].value.lovelace')

FEE=200000             # flat 0.2 ada — ample for this small cert tx
DEPOSITS=502000000     # 500 ada pool + 2 ada stake
CHANGE=$(( FUNDS - DEPOSITS - FEE ))
echo "TXIN=$TXIN  CHANGE=$CHANGE"

cardano-cli dijkstra transaction build-raw \
  --tx-in "$TXIN" \
  --tx-out "$(cat leios/keys/payment.addr)+$CHANGE" \
  --fee "$FEE" \
  --certificate-file leios/keys/stake-reg.cert \
  --certificate-file leios/keys/pool-reg.cert \
  --out-file leios/keys/pool-reg-tx.raw

cardano-cli dijkstra transaction sign \
  --tx-body-file leios/keys/pool-reg-tx.raw \
  --signing-key-file leios/keys/payment.skey \
  --signing-key-file leios/keys/stake.skey \
  --signing-key-file leios/keys/cold.skey \
  --out-file leios/keys/pool-reg-tx.signed

cardano-cli dijkstra transaction submit \
  --tx-file leios/keys/pool-reg-tx.signed