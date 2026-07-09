#! /bin/bash

systemctl --user stop cardano-node

# Reload config
curl -o tmp-testnet/config.json https://book.play.dev.cardano.org/environments-pre/leios/config.json
curl -o tmp-testnet/topology.json https://book.play.dev.cardano.org/environments-pre/leios/topology.json
curl -o tmp-testnet/peer-snapshot.json https://book.play.dev.cardano.org/environments-pre/leios/peer-snapshot.json
curl -o tmp-testnet/byron-genesis.json https://book.play.dev.cardano.org/environments-pre/leios/byron-genesis.json
curl -o tmp-testnet/shelley-genesis.json https://book.play.dev.cardano.org/environments-pre/leios/shelley-genesis.json
curl -o tmp-testnet/alonzo-genesis.json https://book.play.dev.cardano.org/environments-pre/leios/alonzo-genesis.json
curl -o tmp-testnet/conway-genesis.json https://book.play.dev.cardano.org/environments-pre/leios/conway-genesis.json
curl -o tmp-testnet/dijkstra-genesis.json https://book.play.dev.cardano.org/environments-pre/leios/dijkstra-genesis.json


rm leios.full.*
rm -rf tmp-testnet/leios.* tmp-testnet/db

RELAY_FQDN=leios1-rel-a-1.play.dev.cardano.org
wget -c --tries=10 --retry-connrefused  --waitretry=10 --read-timeout=120  https://$RELAY_FQDN/leios.full.tar.zst
wget https://$RELAY_FQDN/leios.full.tar.zst.sha256
sha256sum -c leios.full.tar.zst.sha256
tar -xf leios.full.tar.zst -C tmp-testnet

# mv tmp-testnet/db-leios tmp-testnet/db

systemctl --user start cardano-node
