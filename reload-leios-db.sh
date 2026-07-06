#! /bin/bash

systemctl --user stop cardano-node
rm leios.leiosdb.*
mv tmp-testnet/leios.db tmp-testnet/leios.db-$(date +%s)
mv tmp-testnet/leios.db-shm tmp-testnet/leios.db-shm$(date +%s)
mv tmp-testnet/leios.db-wal tmp-testnet/leios.db-wal$(date +%s)
RELAY_FQDN=leios1-rel-a-1.play.dev.cardano.org
wget -c --tries=10 --retry-connrefused  --waitretry=10 --read-timeout=120  https://$RELAY_FQDN/leios.leiosdb.tar.zst
wget https://$RELAY_FQDN/leios.leiosdb.tar.zst.sha256
sha256sum -c leios.leiosdb.tar.zst.sha256
tar -xf leios.leiosdb.tar.zst -C tmp-testnet
systemctl --user start cardano-node
