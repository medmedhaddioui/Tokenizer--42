import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

// Deploy a treasury for an existing Token42 contract. Parameters are public addresses.
export default buildModule("Token42MultisigModule", (m) => {
  const tokenAddress = m.getParameter("tokenAddress");
  const signer1 = m.getParameter("signer1");
  const signer2 = m.getParameter("signer2");
  const signer3 = m.getParameter("signer3");
  const treasury = m.contract("Token42Multisig", [
    tokenAddress, [signer1, signer2, signer3],
  ]);
  return { treasury };
});
