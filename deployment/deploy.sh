#!/usr/bin/env bash
set -euo pipefail

# Run from any directory; default to a temporary local blockchain.
network="${1:-hardhatMainnet}"
if [[ $# -gt 1 ]]; then
    echo "Usage: bash deployment/deploy.sh [hardhatMainnet|sepolia]" >&2
    exit 2
fi
case "$network" in
    hardhatMainnet|sepolia) ;;
    *) echo "Supported networks: hardhatMainnet or sepolia" >&2; exit 2 ;;
esac

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$script_dir/../code"
if [[ ! -x node_modules/.bin/hardhat ]]; then
    echo "Install dependencies first: cd code && npm ci" >&2
    exit 1
fi
exec ./node_modules/.bin/hardhat ignition deploy ignition/modules/Token42.ts --network "$network"
