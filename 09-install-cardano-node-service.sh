#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVICE_NAME="cardano-node"
SERVICE_FILE="${HOME}/.config/systemd/user/${SERVICE_NAME}.service"

mkdir -p "${HOME}/.config/systemd/user"

cat > "${SERVICE_FILE}" <<EOF
[Unit]
Description=Cardano Node (Leios Testnet)
After=network.target
Wants=network.target

[Service]
Type=simple
WorkingDirectory=${SCRIPT_DIR}/tmp-testnet
ExecStart=nix develop github:input-output-hk/ouroboros-leios#dev-testnet --command \\
  cardano-node run \\
    --config ${SCRIPT_DIR}/tmp-testnet/config.json \\
    --topology ${SCRIPT_DIR}/tmp-testnet/topology.json \\
    --database-path ${SCRIPT_DIR}/tmp-testnet/db \\
    --socket-path ${SCRIPT_DIR}/tmp-testnet/node.socket \\
    --host-addr 0.0.0.0 \\
    --port 3010 \\
    --shelley-kes-key ${SCRIPT_DIR}/leios/keys/kes.skey \\
    --shelley-vrf-key ${SCRIPT_DIR}/leios/keys/vrf.skey \\
    --shelley-operational-certificate ${SCRIPT_DIR}/leios/keys/opcert.cert
Restart=on-failure
RestartSec=5
StandardOutput=journal
StandardError=journal
SyslogIdentifier=cardano-node

[Install]
WantedBy=default.target
EOF

systemctl --user daemon-reload

if systemctl --user is-active --quiet "${SERVICE_NAME}"; then
  systemctl --user restart "${SERVICE_NAME}"
  echo "Service restarted."
else
  systemctl --user enable --now "${SERVICE_NAME}"
  echo "Service installed and started."
fi

echo "Status:"
systemctl --user status "${SERVICE_NAME}" --no-pager
