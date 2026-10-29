# Token42 multisig treasury

## Deployment and scope

- Network: Ethereum Sepolia, chain ID 11155111.
- Treasury: `0x5590a47D2Dd0B46Fbd7318E29dF62499ba6a29E6`.
- Token: `0xB1fb8F1Fba1F82014Ba83cc9e0dAc99B6b7ead72` (T42).
- Source verification completed; token, threshold, and signer configuration checked.
- Funding and a public transfer with two approvals have not yet been demonstrated.

[Verified treasury](https://sepolia.etherscan.io/address/0x5590a47D2Dd0B46Fbd7318E29dF62499ba6a29E6#code)

This is a fixed 2-of-3 treasury for the configured token. Every outgoing transfer
from this treasury requires two distinct authorized approvals. Ordinary wallet
transfers of T42 remain standard ERC20 transfers; the bonus does not impose
multisig on every transfer of T42 everywhere.

The three signer addresses are recorded in [multisig.parameters.json](multisig.parameters.json).
That file contains public addresses only. Anyone deploying a separate instance
must replace them with addresses they control and select the intended token.
The deployer has no special privilege unless also listed as a signer.

## Deploy a treasury

Install dependencies with `npm ci` in code/, using Node.js 24. Configure
SEPOLIA_RPC_URL and SEPOLIA_PRIVATE_KEY in the encrypted Hardhat keystore as
described in [the deployment guide](README.md). Never commit their secret values.
The deploying account needs SepoliaETH; each signer submitting an approval also
needs SepoliaETH.

From code/:

```sh
node ../deployment/deploy_multisig.ts
```

Check the confirmation names Sepolia. The wrapper runs the Ignition module with
the public parameter file. It does not deploy a new Token42 or fund the treasury.
Ignition's local deployment history can resume previous work; rerunning the
command does not necessarily create another instance.

## Source verification

For the recorded deployment use [Standard JSON Input](Token42Multisig.standard-input.json)
and [ABI-encoded constructor arguments](Token42Multisig.constructor-arguments.txt).
Choose Solidity Standard JSON Input, compiler v0.8.34+commit.80d5c536, MIT license.
The input includes optimization enabled with 200 runs and the Osaka EVM target.
Changed source, compiler settings, or constructor arguments require matching new
verification inputs. Verification is not a security audit.

## Demonstrate operation

1. Read token(), REQUIRED_APPROVALS(), and signers(0), signers(1), signers(2).
2. Fund the treasury through the Token42 contract's transfer function. For 100 T42
   use raw amount `100000000000000000000` and the treasury as recipient.
3. As a signer, proposeTransfer with a recipient you control and raw amount
   `10000000000000000000` for 10 T42. Record the proposal ID from the event.
4. Approve that ID with signer 1. An execution simulation must reject one approval.
5. Connect signer 2 on Etherscan and approve the same ID. Check the connected address.
6. Any authorized signer may executeTransaction(id) once two approvals are present.
7. Confirm executed is true, the treasury lost 10 T42, the recipient gained 10 T42,
   and totalSupply is unchanged. A second execution must fail.

Proposing does not approve; approving does not execute. Each approval is an
on-chain transaction signed by that signer's account. hasApproved prevents double
counting. Signers may revokeApproval before execution. Approved proposals do not
expire. A failed token transfer reverts the executed flag so the proposal can be
retried after funding. SafeERC20 checks transfer success. There is no arbitrary
call, allowance-granting, or emergency withdrawal path bypassing the threshold.

Signer addresses and token address cannot change. Losing access to two signers
locks the treasury's tokens. Only deposit the configured T42 token; other assets
have no recovery function. Three accounts controlled by one person demonstrate
the mechanics, but independent control is needed for real separation of authority.

## Tests

From code/:

```sh
npm run typecheck
node node_modules/typescript/bin/tsc --project ../deployment/tsconfig.json
npm test
```

The 16 treasury tests cover setup, input validation, permissions, proposal IDs,
approval isolation, threshold enforcement, duplicate approvals, revocation,
execution, replay prevention, and insufficient-funds retry. Five ERC20 tests
continue to cover the mandatory token. Local tests are not a professional audit.
