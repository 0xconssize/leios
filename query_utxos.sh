#! /bin/bash

watch cardano-cli query utxo --address $(cat leios/keys/payment.addr)
