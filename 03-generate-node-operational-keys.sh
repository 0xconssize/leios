#! /bin/bash

if [ ! -d leios/keys ]; then
  echo "Keys directory does not exist. Create the leios/keys directory to generate keys."
  exit 1
fi

if [ -f leios/keys/cold.vkey ] || [ -f leios/keys/cold.skey ] || \
   [ -f leios/keys/kes.vkey ] || [ -f leios/keys/kes.skey ] || \
   [ -f leios/keys/vrf.vkey ] || [ -f leios/keys/vrf.skey ]; then
  echo "Operational keys already exist. Remove the existing keys to generate new ones."
  echo "Do you want to overwrite the existing keys? (y/n)"
  read answer
  if [ "$answer" != "y" ]; then
    echo "Aborting key generation."
    exit 1  
  fi
fi

# Cold keys (your pool's identity — keep offline / backed up)
cardano-cli dijkstra node key-gen \
  --cold-verification-key-file leios/keys/cold.vkey \
  --cold-signing-key-file leios/keys/cold.skey \
  --operational-certificate-issue-counter-file leios/keys/opcert.counter

# KES keys (hot keys, rotated periodically)
cardano-cli dijkstra node key-gen-KES \
  --verification-key-file leios/keys/kes.vkey \
  --signing-key-file leios/keys/kes.skey

# VRF keys (used to win block-production slots)
cardano-cli dijkstra node key-gen-VRF \
  --verification-key-file leios/keys/vrf.vkey \
  --signing-key-file leios/keys/vrf.skey