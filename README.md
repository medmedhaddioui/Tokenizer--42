# Token42

Token42 (T42) is an educational ERC-20 token deployed on Ethereum Sepolia.
It demonstrates token creation, transfers, and spending approvals.

## Project choices

- Solidity: used to write the smart contract.
- Ethereum Sepolia: allows public testing without real money.
- ERC-20: provides a standard interface for fungible tokens.
- OpenZeppelin: provides the inherited ERC-20 implementation.
- Hardhat 3: used to compile, test, and deploy the contract.
- Fixed supply: all tokens are created at deployment, keeping the supply policy simple and preventing additional minting.

## Token details

- Name: Token42
- Symbol: T42
- Decimals: 18
- Total supply: 1,000,000 T42
- Initial recipient: the deploying account
- Additional minting: not available
- Owner-only administrative functions: none

## Deployment

- Network: Ethereum Sepolia
- Chain ID: 11155111
- Contract: `0xB1fb8F1Fba1F82014Ba83cc9e0dAc99B6b7ead72`
- Source code verified on Etherscan.

[View the contract](https://sepolia.etherscan.io/address/0xB1fb8F1Fba1F82014Ba83cc9e0dAc99B6b7ead72#code)

A transfer of 10 T42 from the deploying account to a second account was successfully demonstrated on Sepolia.

## Run locally

Use Node.js 24 and npm. From the repository root:

```sh
cd code
npm ci
npx hardhat test
```

`npm test` also runs the
tests, and `npm run typecheck` builds the contracts and checks TypeScript.
Local tests require no private key or testnet funds.

The five token tests cover initial supply, transfers, insufficient balances,
approved spending, and rejection of spending without approval. Sixteen additional
tests cover the multisig treasury.

## Repository layout

- `code/`: contracts, tests, and Hardhat project.
- `deployment/`: runnable deployment script, verification input, and deployment documentation.
- `documentation/`: token usage and explanations.

## Documentation

- [Deployment and source verification](deployment/README.md)
- [Token operation, security, and evaluation demonstration](documentation/README.md)
- [Mandatory requirements and submission checklist](documentation/SUBMISSION.md)

From the repository root, run `node deployment/deploy.ts` for a temporary local
deployment. See the deployment guide before using `node deployment/deploy.ts sepolia`.

Deployment wrappers use TypeScript with Node.js 24 for readable path handling and command execution.
Contracts remain Solidity and Ignition deployment modules remain TypeScript.
For the multisig treasury, see [the bonus guide](deployment/BONUS.md).

The bonus treasury is deployed and source-verified on Ethereum Sepolia at
`0x5590a47D2Dd0B46Fbd7318E29dF62499ba6a29E6`. It requires two of three
signers for outgoing treasury transfers. The public funding/approval/execution
demonstration remains pending; ordinary wallet transfers remain standard ERC20.
