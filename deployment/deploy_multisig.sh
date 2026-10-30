#!/usr/bin/env bash
set -euo pipefail

# This wrapper deploys the treasury on Sepolia and accepts no arguments.
if [[ $# -eq 1 && "$1" == "--help" ]]; then
    echo "Usage: bash deployment/deploy_multisig.sh (deploys on Sepolia)"
    exit 0
fi
if [[ $# -ne 0 ]]; then
    echo "Usage: bash deployment/deploy_multisig.sh" >&2
    exit 2
fi

# Find the project relative to this script, then enter the Hardhat folder.
script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$script_dir/../code"

# Dependencies must be installed before deployment.
if [[ ! -x node_modules/.bin/hardhat ]]; then
    echo "Install dependencies first: run npm ci inside code/" >&2
    exit 1
fi

# These parameters contain public token/signer addresses, not private keys.
parameters="$script_dir/multisig.parameters.json"
if [[ ! -f "$parameters" ]]; then
    echo "Missing parameter file: $parameters" >&2
    exit 1
fi

# Hardhat loads the signing key through the existing configuration and keystore.
exec ./node_modules/.bin/hardhat ignition deploy     ignition/modules/Token42Multisig.ts --network sepolia --parameters "$parameters"
