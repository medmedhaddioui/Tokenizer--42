# Token42: operation and usage

## Purpose

Token42 is an educational fungible token: each whole T42 has the same role as
any other whole T42. It represents transferable demonstration units, not a claim
to money or assets. The project demonstrates ERC-20 balances, transfers, and
spending permissions on Ethereum Sepolia without using real money.

## Requirements and project map

For reading the public contract, a browser and internet access are sufficient.
For sending a transaction, use an Ethereum wallet controlling an account with
Sepolia ETH for fees. A recipient needs no ETH just to receive T42.
For local development, use Node.js 24 and npm (Git is also needed to install the
forge-std dependency). See the [root README](../README.md) and
[deployment guide](../deployment/README.md).

The source is [Token42.sol](../code/contracts/Token42.sol). The deployed contract is
[on Sepolia Etherscan](https://sepolia.etherscan.io/address/0xB1fb8F1Fba1F82014Ba83cc9e0dAc99B6b7ead72#code).
Chain ID: `11155111`. Contract address:
`0xB1fb8F1Fba1F82014Ba83cc9e0dAc99B6b7ead72`.

## How the source works

- The MIT SPDX comment declares the source license.
- `pragma solidity ^0.8.34` permits compatible compiler versions starting at
  0.8.34 and below 0.9.0. This deployment used exactly 0.8.34.
- The import brings in OpenZeppelin's ERC20 implementation.
- `is ERC20` inherits its balance, transfer, and allowance logic.
- The constructor runs once at deployment and sets the name `Token42` and ticker `T42`.
- `_mint(msg.sender, 1_000_000 * 10 ** decimals())` creates the entire initial
  supply for the deploying account. During the Solidity tests, the test contract
  is the deployer; on Sepolia, the wallet account is the deployer.

## Supply and units

There are 1,000,000 whole T42 and 18 decimals. Internally, balances are integers
in smallest units. Divide raw balances by 10^18 to obtain whole-token amounts.

| Whole T42 | Raw amount passed to contract |
| --- | --- |
| 1 | `1000000000000000000` |
| 10 | `10000000000000000000` |
| 100 | `100000000000000000000` |
| 1,000,000 | `1000000000000000000000000` |

Entering `10` directly as a contract amount sends only 0.00000000000000001 T42.
Transfers move existing tokens; they do not change total supply. Sepolia ETH
is a different asset used for transaction fees.

## ERC-20 interface

| Function | Meaning |
| --- | --- |
| `name()`, `symbol()`, `decimals()` | Read token metadata |
| `totalSupply()` | Read supply in smallest units |
| `balanceOf(account)` | Read an account's token balance |
| `transfer(to, value)` | Move the caller's tokens to another account |
| `approve(spender, value)` | Set how much another address may spend from the caller |
| `allowance(owner, spender)` | Read the remaining spending permission |
| `transferFrom(from, to, value)` | Spend tokens using the caller's allowance from `from` |

Approval itself moves no tokens. For example, A approves B for 100 T42, then B
calls `transferFrom(A, C, 40 T42)`. A loses 40, C gains 40, and B's ordinary
finite allowance becomes 60. A new `approve` replaces the allowance; it does
not add to it. An approval of zero revokes the remaining permission. When
changing an existing nonzero allowance, first revoke it and wait for that
transaction to confirm before setting the replacement, to reduce the known
allowance-change race risk. Maximum uint256 approvals act as unlimited
allowances in this OpenZeppelin implementation; finite approvals are simpler
for this demonstration.

Successful transfers emit `Transfer`; approvals emit `Approval`. A transaction
hash identifies an individual transaction. It differs from the contract address,
which identifies the token program, and wallet addresses, which identify holders.

## Security and privileges

There is no Ownable administrator, privileged mint function, pause function,
blacklist, upgrade mechanism, or public burn function in Token42. The deployer
receives the initial tokens but has no extra administrative rights. `_mint` is
internal and is only used in the constructor; users cannot call it externally.

An account can move its own balance or spend another account's balance within
an explicit allowance. Transfers fail for insufficient balances, insufficient
allowances, and invalid zero-address recipients under OpenZeppelin's checks.
Zero-amount transfers are permitted by ERC-20. There are no transfer taxes.

Keep private keys and wallet recovery phrases private and outside Git. A key
controls the same account on other EVM networks too. Verification proves source
matches deployed bytecode; it is not a security audit. This project has not
received an independent security audit.

## Read the public token

Open **Contract → Read Contract** on the explorer. Reading needs no connected
wallet and no gas fee. Inspect the metadata and total supply, then use
`balanceOf` with a holder's public address and click **Query**. The contract's
ETH balance is not the token supply or the deployer's T42 balance.

## Demonstrate a transfer

1. Select Sepolia in MetaMask and choose the account holding T42.
2. On the explorer select **Contract → Write Contract**, then connect that account.
3. Expand `transfer`, enter a recipient address you control, and enter
   `10000000000000000000` to send 10 T42. Do not apply another scale multiplier.
4. Review the network, account, recipient, and amount, then confirm in the wallet.
5. Open the transaction and check **Success** and **ERC-20 Tokens Transferred**.
6. Query the sender and recipient with `balanceOf` and compare the changes.

The project demonstration successfully sent 10 T42 to
`0x783620E9032Dd07ef8f36016087Cb2531AFc2dfF`. An earlier transfer sent 10 smallest
units, so the recipient's cumulative balance after both transfers was
`10000000000000000010` raw units. Later transfers may change these balances.

To show allowance behavior locally, run the approval test described below.
For an optional public demonstration, A calls `approve(B, amount)`, B connects
and calls `transferFrom(A, recipient, amount)`, and you inspect balances and
`allowance(A, B)`. Both transaction senders need Sepolia ETH for their own fees.

## Local checks

From the repository root:

```sh
cd code
# If nvm is installed, select the version in .nvmrc:
nvm use
npm ci
npm test
npm run typecheck
```

Without nvm, install/select Node.js 24 using your preferred method. Local tests
use simulated accounts and need neither wallet secrets nor Sepolia funds.
Each Solidity test receives a fresh contract through `setUp()`.

The five tests cover initial supply and deployer balance, successful transfer,
rejection of an excessive transfer, approval followed by delegated spending,
and rejection of delegated spending without approval. `vm.prank` changes the
sender for a test call; `vm.expectRevert` asserts that a call fails as expected.

## Evaluation demonstration

Explain the token's purpose and choices; show the short source and inherited
ERC-20 functions; run the tests; open the verified public contract; read supply
and balances; explain or repeat a transfer; and describe ownership, allowances,
units, and key handling. Multisig is the optional bonus and is not implemented.
