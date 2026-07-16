#!/bin/bash

if [ "$#" -ne 4 ]; then
    echo "Usage: create-pool-metadata-file.sh POOLNAME POOLDESCRIPTION POOLTICKER POOLHOMEPAGE"
    exit 2
fi

STAKE_POOL_NAME=$1
STAKE_POOL_DESCRIPTION=$2
STAKE_POOL_TICKER=$3
STAKE_POOL_HOMEPAGE=$4

# Create metadata file
echo "{\"name\":\"$STAKE_POOL_NAME\",\"description\":\"$STAKE_POOL_DESCRIPTION\",\"ticker\":\"$STAKE_POOL_TICKER\",\"homepage\":\"$STAKE_POOL_HOMEPAGE\"}" | jq '.' > leios/stake-pool-metadata.json
cat leios/stake-pool-metadata.json

# Hash Metadata file
cardano-cli dijkstra stake-pool metadata-hash \
  --pool-metadata-file leios/stake-pool-metadata.json > leios/stake-pool-metadata.hash

echo "Metadata file is now located in leios/stake-pool-metadata.json. Please upload to a < 65 character URL and note the URL for later in the registration process"