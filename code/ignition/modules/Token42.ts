import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("Token42Module", (m) => {
  const token = m.contract("Token42");

  return { token };
});