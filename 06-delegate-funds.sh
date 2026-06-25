#! /bin/bash

cardano-cli dijkstra stake-address stake-delegation-certificate \
  --stake-verification-key-file leios/keys/stake.vkey \
  --cold-verification-key-file leios/keys/cold.vkey \
  --out-file leios/keys/delegation.cert

UTXO=$(cardano-cli dijkstra query utxo --address "$(cat leios/keys/payment.addr)")
TXIN=$(echo "$UTXO" | jq -r 'keys[0]')
FUNDS=$(echo "$UTXO" | jq -r '.[keys[0]].value.lovelace')

FEE=200000
CHANGE=$(( FUNDS - FEE ))

cardano-cli dijkstra transaction build-raw \
  --tx-in "$TXIN" \
  --tx-out "$(cat leios/keys/payment.addr)+$CHANGE" \
  --fee "$FEE" \
  --certificate-file leios/keys/delegation.cert \
  --out-file leios/keys/delegation-tx.raw

cardano-cli dijkstra transaction sign \
  --tx-body-file leios/keys/delegation-tx.raw \
  --signing-key-file leios/keys/payment.skey \
  --signing-key-file leios/keys/stake.skey \
  --out-file leios/keys/delegation-tx.signed

cardano-cli dijkstra transaction submit \
  --tx-file leios/keys/delegation-tx.signed