import { existsSync, readFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { spawnSync } from "node:child_process";

// Run with Node.js 24, which supports this TypeScript syntax directly.
const inputs = process.argv.slice(2);
if (inputs.length === 1 && inputs[0] === "--help") {
  console.log("Usage: node deployment/deploy.ts [hardhatMainnet|sepolia]");
  process.exit(0);
}
// Default to a temporary local blockchain, not Ethereum mainnet.
const network = inputs[0] ?? "hardhatMainnet";
if (inputs.length > 1 || !["hardhatMainnet", "sepolia"].includes(network)) {
  console.error("Usage: node deployment/deploy.ts [hardhatMainnet|sepolia]");
  process.exit(2);
}

// Locate Hardhat using paths relative to this script, not the terminal directory.
const deploymentFolder = dirname(fileURLToPath(import.meta.url));
const codeFolder = resolve(deploymentFolder, "../code");
const hardhatFolder = resolve(codeFolder, "node_modules/hardhat");
const packageFile = resolve(hardhatFolder, "package.json");

if (!existsSync(packageFile)) {
  console.error("Install dependencies first: run npm ci inside code/");
  process.exit(1);
}

// Read the installed package's CLI entry point instead of relying on shell wrappers.
const hardhatPackage = JSON.parse(readFileSync(packageFile, "utf8"));
const hardhatCli = resolve(hardhatFolder, hardhatPackage.bin.hardhat);

const args: string[] = [
  "ignition", "deploy", "ignition/modules/Token42.ts", "--network", network,
];

// Reuse this Node executable. Keep prompts interactive and avoid invoking a shell.
const result = spawnSync(process.execPath, [hardhatCli, ...args], {
  cwd: codeFolder,
  stdio: "inherit",
});
if (result.error) console.error(result.error.message);
process.exit(result.status ?? (result.signal === "SIGINT" ? 130 : 1));
