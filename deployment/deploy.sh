#!/usr/bin/env bash
set -euo pipefail

# Accept one network name, or --help. Default to a temporary local network.
if [[ $# -eq 1 && "$1" == "--help" ]]; then
    echo "Usage: bash deployment/deploy.sh [hardhatMainnet|sepolia]"
    exit 0
fi
network="${1:-hardhatMainnet}"
if [[ $# -gt 1 ]]; then
    echo "Usage: bash deployment/deploy.sh [hardhatMainnet|sepolia]" >&2
    exit 2
fi
case "$network" in
    hardhatMainnet|sepolia) ;;
    *) echo "Supported networks: hardhatMainnet or sepolia" >&2; exit 2 ;;
esac

# Find the project relative to this script, then enter the Hardhat folder.
script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$script_dir/../code"

# Dependencies must be installed before deployment.
if [[ ! -x node_modules/.bin/hardhat ]]; then
    echo "Install dependencies first: run npm ci inside code/" >&2
    exit 1
fi

# Replace this script with Hardhat; password prompts and exit status are preserved.
exec ./node_modules/.bin/hardhat ignition deploy     ignition/modules/Token42.ts --network "$network"
