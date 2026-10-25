// SPDX-License-Identifier: MIT
pragma solidity ^0.8.34;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token42 is ERC20 {
    constructor() ERC20("Token42", "T42") {
        // Create one million tokens and give them to the deployer.
        _mint(msg.sender, 1_000_000 * 10 ** decimals());
    }
}