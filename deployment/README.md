# Token42 deployment guide

Deployment creates an instance of the token contract on a blockchain. Verification
publishes its source on an explorer and checks that it matches the deployed code.

## Existing deployment

- Network: Ethereum Sepolia (chain ID `11155111`).
- Contract: `0xB1fb8F1Fba1F82014Ba83cc9e0dAc99B6b7ead72`.
- Deployer: `0xA0f63a7c61671E05b6e1E642823A4f088E5C771B`.
- Name and symbol: Token42 (`T42`).
- Initial supply: 1,000,000 T42, assigned to the deployer.
- Source verification: completed on Etherscan.

[Open the verified contract](https://sepolia.etherscan.io/address/0xB1fb8F1Fba1F82014Ba83cc9e0dAc99B6b7ead72#code)

You can inspect and use this deployment without deploying another token.

## 1. Prepare the project

Use Node.js 24 and npm. From the repository root:

```sh
cd code
npm ci
npx hardhat test
```

Run all remaining commands in this guide from `code/`.

The runnable entry point is [deploy.ts](deploy.ts). From the repository root,
use `node deployment/deploy.ts` for a local deployment or
`node deployment/deploy.ts sepolia` for Sepolia. It locates the Hardhat project
automatically and calls the module below. These wrappers require Node.js 24 and run in WSL/Linux/macOS. No additional runtime packages are needed.

The deployment module is [Token42.ts](../code/ignition/modules/Token42.ts).
It tells Hardhat Ignition to deploy `Token42` without constructor arguments.
It lives inside the Hardhat project so it can resolve the project's dependencies.

## 2. Practice locally

```sh
node ../deployment/deploy.ts hardhatMainnet
```

Despite its name, `hardhatMainnet` is configured as a simulated network, not
Ethereum mainnet. This temporary blockchain disappears when the command ends.
Its address is not the public Sepolia deployment address.

## 3. Prepare a Sepolia account

Use an Ethereum account you control, preferably dedicated to development.
Enable test networks in MetaMask and select Sepolia. Obtain free Sepolia ETH
from a faucet to pay deployment transaction fees.

[Google Cloud Sepolia faucet](https://cloud.google.com/application/web3/faucet/ethereum/sepolia)

Faucet availability and eligibility may change. No real-money purchase is
required for this project. Sepolia ETH pays fees; T42 is the separate token
created by this contract.

## 4. Save the connection and signing key

The existing configuration reads two variables:

| Variable | Purpose |
| --- | --- |
| `SEPOLIA_RPC_URL` | Server endpoint used to communicate with Sepolia |
| `SEPOLIA_PRIVATE_KEY` | Ethereum private key used to sign transactions |

Save them using Hardhat's encrypted keystore:

```sh
npx hardhat keystore set SEPOLIA_RPC_URL
npx hardhat keystore set SEPOLIA_PRIVATE_KEY
```

On first use, create and safely retain a keystore password. At subsequent
password prompts, use that password, not your MetaMask password.

For the RPC value, this deployment used:

```text
https://ethereum-sepolia-rpc.publicnode.com
```

For the private-key value, use the deployment account's Ethereum private key:
`0x` followed by 64 hexadecimal characters. It is not the public wallet address
or the recovery phrase. Enter it only at the hidden keystore prompt. Never put
it in source files, screenshots, documentation, or Git. The same key controls
the account on other Ethereum-compatible networks too.

To correct a saved value, repeat its `keystore set` command with `--force`.

## 5. Deploy to Sepolia

```sh
node ../deployment/deploy.ts sepolia
```

Unlock the keystore when prompted. Check that the confirmation names Sepolia
and chain ID `11155111` before accepting. After success, record the printed
contract address. A fresh deployment may have a different address from the
existing deployment documented above.

Ignition saves the public deployment records under
`code/ignition/deployments/chain-11155111/`, including the deployed address,
transaction journal, artifacts, and compiler input. Preserve these records:
Ignition uses them to track and resume deployment. Repeating the command with
the same records does not necessarily create another instance. These generated
records are kept locally and excluded from Git. A fresh clone has no deployment
history and can deploy a new instance; record its new address. For evaluation,
practice a fresh local deployment with the script before any public deployment.

## 6. Verify the source on Etherscan

The existing deployment has already been verified. Its exact Solidity Standard
JSON Input is saved as [Token42.standard-input.json](Token42.standard-input.json).
This contains the Solidity source, imported OpenZeppelin source, and compiler
settings; it contains no wallet credentials.

The recorded deployment used:

| Setting | Value |
| --- | --- |
| Compiler | `v0.8.34+commit.80d5c536` |
| Input format | Solidity Standard JSON Input |
| Optimizer | Enabled, 200 runs |
| EVM target | `osaka` |
| OpenZeppelin Contracts | `5.6.1` |
| License | MIT |
| Constructor arguments | None |

To verify a deployment with matching source and settings:

1. Open its address on Sepolia Etherscan.
2. Select **Contract → Verify and Publish**.
3. Choose **Solidity (Standard-Json-Input)**, the matching compiler, and MIT.
4. Upload the Standard JSON Input file.
5. Leave constructor arguments empty and submit verification.

For a changed contract or build, use that deployment's saved build-info file
and export only its `input` object as the upload JSON. Do not upload the entire
Hardhat build-info wrapper or assume the file in this folder matches a new build.
Verification does not deploy a new contract or require a gas fee.

## 7. Check the deployed token

On **Contract → Read Contract**, inspect:

- `name()`: `Token42`.
- `symbol()`: `T42`.
- `decimals()`: `18`.
- `totalSupply()`: `1000000000000000000000000` (1,000,000 T42).
- `balanceOf(address)`: the supplied account's balance in smallest units.

A transfer of 10 T42 to a second controlled account was demonstrated successfully
on Sepolia. To repeat a demonstration, use **Write Contract → transfer** with a
recipient address you control and `10000000000000000000` as the raw value.
That is 10 T42; entering `10` sends only 10 smallest units. Do not apply an
additional scale multiplier to the already-scaled value.

The sending account pays gas in Sepolia ETH. The recipient does not need ETH
to receive tokens. Check the transaction status and token transfer event on
Etherscan, then query both balances to confirm the result. Each successful
transfer changes balances, so do not expect the deployer to retain the entire
initial supply after the demonstration.
