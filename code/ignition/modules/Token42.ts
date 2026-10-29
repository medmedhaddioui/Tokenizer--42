// Import the helper used to describe a deployment plan.
import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

// Export the plan so the `hardhat ignition deploy` command can load it.
// "Token42Module" identifies this plan; it is not the token's display name.
// `m` is Ignition's helper for declaring deployment actions.
export default buildModule("Token42Module", (m) => {
  // Plan a deployment of the Solidity contract declared as `contract Token42`.
  // Its constructor takes no arguments: name, symbol, and supply are in Solidity.
  // This describes an action; Ignition executes it when deployment is requested.
  // The command's --network option selects the network, not this module.
  const token = m.contract("Token42");

  // Expose the planned contract as a result of this module.
  return { token };
});
