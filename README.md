# Leios Testnet — Stake Pool Setup Scripts

> **Follow the official guides.** These scripts are a convenience wrapper around the official documentation and may lag behind protocol changes. Always refer to the authoritative sources:
>
> - [Install and run a node](https://leios.cardano-scaling.org/docs/testnet/getting-started)
> - [Register a stake pool](https://leios.cardano-scaling.org/docs/testnet/register-stake-pool)

## Prerequisites

1. **Run a relay node first** and wait for it to fully sync (`syncProgress: "100.00"`).
   The Nix path (used by these scripts) starts the relay with:

   ```bash
   nix run github:input-output-hk/ouroboros-leios#leios-testnet-relay
   ```

   This populates `./tmp-testnet/` with the config, genesis files, and socket.

2. **Enter the dev shell** so `cardano-cli` and `cardano-node` are on your `PATH`:

   ```bash
   nix develop github:input-output-hk/ouroboros-leios#dev-testnet
   ```

3. **Set environment variables** (do this in every new shell):
   ```bash
   source 00-set-environment-variables.sh
   ```
   This exports `CARDANO_NODE_NETWORK_ID=164` and `CARDANO_NODE_SOCKET_PATH`.

## Scripts

Run them in order. Each script corresponds to a step in the official guide.

| Script                                 | What it does                                             |
| -------------------------------------- | -------------------------------------------------------- |
| `00-set-environment-variables.sh`      | Export env vars needed by `cardano-cli`                  |
| `01-generate-cardano-address-keys.sh`  | Step 1 — Generate payment and stake keys                 |
| `03-generate-node-operational-keys.sh` | Step 3 — Generate cold, KES, and VRF keys                |
| `04-issue-operational-certificate.sh`  | Step 4 — Issue the operational certificate               |
| `05-register-certificates.sh`          | Step 5 — Register stake address and pool on-chain        |
| `06-delegate-funds.sh`                 | Step 6 — Delegate your stake to your pool                |
| `07-verify-delegation.sh`              | Step 7 — Verify pool registration and delegation         |
| `08-run-node.sh`                       | Step 8 — Run the node as a block producer (foreground)   |
| `09-install-cardano-node-service.sh`   | Step 8 (alternative) — Install as a systemd user service |

> **Step 2** (fund your address from the [faucet](https://faucet.leios.play.dev.cardano.org/basic-faucet)) has no script — copy the address printed by script `01` and paste it into the faucet.

Keys are stored under `leios/keys/`. **Back them up** — they control your pool.

## Running as a systemd service

Instead of running `08-run-node.sh` in the foreground, you can install the node as a persistent user service:

```bash
./09-install-cardano-node-service.sh   # installs/restarts the service
journalctl --user -u cardano-node -f   # follow logs
```

The script is idempotent: re-run it whenever you move the repository or regenerate keys.

PRs are welcome.
