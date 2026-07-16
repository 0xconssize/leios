#! /bin/bash

# Update the pool registration without registering the stake address again.

DEFAULT_PLEDGE=1000000000
DEFAULT_COST=170000000
DEFAULT_MARGIN=0.05
DEFAULT_RELAY_TYPE=ipv4
RELAY_PORT=3010

read -r -p "Pool pledge in lovelace [$DEFAULT_PLEDGE]: " pool_pledge
pool_pledge=${pool_pledge:-$DEFAULT_PLEDGE}

read -r -p "Pool cost in lovelace [$DEFAULT_COST]: " pool_cost
pool_cost=${pool_cost:-$DEFAULT_COST}

read -r -p "Pool margin (for example, 0.05) [$DEFAULT_MARGIN]: " pool_margin
pool_margin=${pool_margin:-$DEFAULT_MARGIN}

read -r -p "Relay type (ipv4, ipv6, or host) [$DEFAULT_RELAY_TYPE]: " relay_type
relay_type=${relay_type:-$DEFAULT_RELAY_TYPE}

read -r -p "Enter the relay IP address or hostname: " relay_address

case "$relay_type" in
  ipv4)
    relay_args=(--pool-relay-ipv4 "$relay_address" --pool-relay-port "$RELAY_PORT")
    ;;
  ipv6)
    relay_args=(--pool-relay-ipv6 "$relay_address" --pool-relay-port "$RELAY_PORT")
    ;;
  host)
    relay_args=(--single-host-pool-relay "$relay_address" --pool-relay-port "$RELAY_PORT")
    ;;
  *)
    echo "Invalid relay type: $relay_type. Choose ipv4, ipv6, or host."
    exit 1
    ;;
esac

metadata_args=()
read -r -p "Include pool metadata? (y/N): " include_metadata
if [[ "$include_metadata" =~ ^[Yy]$ ]]; then
  read -r -p "Enter the metadata URL: " metadata_url
  if [[ ! -f leios/stake-pool-metadata.hash ]]; then
    echo "Metadata hash file not found: leios/stake-pool-metadata.hash"
    echo "Run create-metadata.sh before including metadata."
    exit 1
  fi
  metadata_hash=$(cat leios/stake-pool-metadata.hash)
  metadata_args=(--metadata-url "$metadata_url" --metadata-hash "$metadata_hash")
fi

cardano-cli dijkstra stake-pool registration-certificate \
  --cold-verification-key-file leios/keys/cold.vkey \
  --vrf-verification-key-file leios/keys/vrf.vkey \
  --pool-pledge "$pool_pledge" \
  --pool-cost "$pool_cost" \
  --pool-margin "$pool_margin" \
  --pool-reward-account-verification-key-file leios/keys/stake.vkey \
  --pool-owner-stake-verification-key-file leios/keys/stake.vkey \
  "${relay_args[@]}" \
  "${metadata_args[@]}" \
  --out-file leios/keys/pool-reg-update.cert

UTXO=$(cardano-cli dijkstra query utxo --address "$(cat leios/keys/payment.addr)")
TXIN=$(echo "$UTXO" | jq -r 'keys[0]')
FUNDS=$(echo "$UTXO" | jq -r '.[keys[0]].value.lovelace')

FEE=200000
CHANGE=$(( FUNDS - FEE ))
echo "TXIN=$TXIN  CHANGE=$CHANGE"

cardano-cli dijkstra transaction build-raw \
  --tx-in "$TXIN" \
  --tx-out "$(cat leios/keys/payment.addr)+$CHANGE" \
  --fee "$FEE" \
  --certificate-file leios/keys/pool-reg-update.cert \
  --out-file leios/keys/pool-reg-update-tx.raw

cardano-cli dijkstra transaction sign \
  --tx-body-file leios/keys/pool-reg-update-tx.raw \
  --signing-key-file leios/keys/payment.skey \
  --signing-key-file leios/keys/stake.skey \
  --signing-key-file leios/keys/cold.skey \
  --out-file leios/keys/pool-reg-update-tx.signed

cardano-cli dijkstra transaction submit \
  --tx-file leios/keys/pool-reg-update-tx.signed
