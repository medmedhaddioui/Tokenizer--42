# Mandatory requirements and submission

| Subject requirement | Project evidence |
| --- | --- |
| Token name contains 42 | `Token42` |
| Blockchain-compatible token standard | ERC-20 inherited from OpenZeppelin on Ethereum Sepolia |
| Root README explains choices | [README](../README.md) |
| Readable, commented token source under code/ | [Token42.sol](../code/contracts/Token42.sol) |
| Separate deployment materials | [deployment/](../deployment/README.md), including a runnable [deployment script](../deployment/deploy.ts), instructions, and verification input |
| Public blockchain deployment, ticker, explorer publication | T42 at the Sepolia address linked in the root README; source verified |
| Contract address and network in Git repository contents | Root README and deployment guide |
| Root documentation/ explains operation and usage | [Usage and security guide](README.md) |
| Demonstrate basic operations and consider privileges | Public transfer demonstration, five local tests, documented allowance and supply model |

The optional [multisig treasury](../deployment/README.md#multisig-treasury-bonus) is implemented, tested,
deployed, and source-verified. Its public funding and two-approval transfer
demonstration is still pending. A video is not required.

## Final local check

From the repository root, with Node.js 24 selected:

```sh
cd code
npm ci
npm run typecheck
node node_modules/typescript/bin/tsc --project ../deployment/tsconfig.json
npm test
```

## Submit through Git

The files must be committed and pushed to the repository assigned for evaluation;
files existing only on your computer are not a submitted project.

Project remote: `git@github.com:medmedhaddioui/Tokenizer--42.git`.
Confirm that this is also the repository expected by your evaluation platform.

From the repository root, review and stage the deliverable files:

```sh
git status --short
git add README.md .gitignore code deployment documentation
git diff --cached --stat
git diff --cached --check
```

Review the staged files before committing. Include package-lock.json, the token
source, tests, configuration, deployment script/module, and
documentation. Exclude local Ignition deployment records, node_modules, generated working build/cache output,
private keys, passwords, and environment files containing secrets. The encrypted
Hardhat keystore is outside this repository and must remain private.

Commit the reviewed files, configure the actual evaluation repository URL as
the Git remote, and push the intended branch. Do not substitute another person's
repository or an example address for your own submission destination.

Finally, confirm the files are visible in the evaluation repository. Be ready
to explain the source and demonstrate the token; written files do not replace
the oral/code review.

## Live evaluation checklist

- Explain platform/language choices, ERC-20 inheritance, constructor and decimal units.
- Explain token ownership versus administrator roles; this token has no administrator.
- Reproduce installation and tests, then demonstrate deployment with the evaluator.
- Show the recorded public contract, name, ticker, supply, balances and a transfer.
- Explain approve/allowance/transferFrom and show successful and rejected local cases.
- For bonus, demonstrate insufficient approvals, two distinct approvals and one-time execution.
- Confirm the school's submission repository is the one receiving the final commit.

The public multisig transfer demonstration remains outstanding. A deployed and
verified treasury alone does not establish that this live demonstration was done.
