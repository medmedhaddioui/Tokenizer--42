// SPDX-License-Identifier: MIT
pragma solidity ^0.8.34;

import {Test} from "forge-std/Test.sol";
import {Token42} from "./Token42.sol";

contract Token42Test is Test {
    Token42 token;

    function setUp() public {
        token = new Token42();
    }
    function test_Transfer() public {
        address recipient = address(0xBEEF);
        uint256 amount = 100 * 10 ** 18;
        uint256 initialBalance = token.balanceOf(address(this));
    
        bool success = token.transfer(recipient, amount);
    
        assertTrue(success);
        assertEq(token.balanceOf(recipient), amount);
        assertEq(
            token.balanceOf(address(this)),
            initialBalance - amount
        );
    }
    function test_InitialSupply() public view {
        uint256 expectedSupply = 1_000_000 * 10 ** 18;

        assertEq(token.totalSupply(), expectedSupply);
        assertEq(token.balanceOf(address(this)), expectedSupply);
    }
    function test_TransferInsufficientBalance() public {
    uint256 balance = token.balanceOf(address(this));

    vm.expectRevert(
        abi.encodeWithSignature(
            "ERC20InsufficientBalance(address,uint256,uint256)",
            address(this),
            balance,
            balance + 1
        )
    );

    token.transfer(address(0xBEEF), balance + 1);
}
function test_ApproveAndTransferFrom() public {
    address spender = address(0xCAFE);
    address recipient = address(0xBEEF);

    uint256 approvedAmount = 100 * 10 ** 18;
    uint256 transferAmount = 40 * 10 ** 18;
    uint256 initialBalance = token.balanceOf(address(this));

    // Allow spender to spend up to 100 of our tokens.
    token.approve(spender, approvedAmount);

    assertEq(
        token.allowance(address(this), spender),
        approvedAmount
    );

    // Make the next call as spender, who sends 40 of our tokens.
    vm.prank(spender);
    token.transferFrom(address(this), recipient, transferAmount);

    assertEq(token.balanceOf(recipient), transferAmount);
    assertEq(
        token.balanceOf(address(this)),
        initialBalance - transferAmount
    );

    // The spender can still spend the remaining 60 tokens.
    assertEq(
        token.allowance(address(this), spender),
        approvedAmount - transferAmount
    );
}
function test_TransferFromWithoutApproval() public {
    address spender = address(0xCAFE);
    address recipient = address(0xBEEF);
    uint256 amount = 10 * 10 ** 18;

    vm.prank(spender);
    vm.expectRevert(
        abi.encodeWithSignature(
            "ERC20InsufficientAllowance(address,uint256,uint256)",
            spender,
            0,
            amount
        )
    );

    token.transferFrom(address(this), recipient, amount);
}
}