// SPDX-License-Identifier: MIT
pragma solidity ^0.8.34;

import {Test} from "forge-std/Test.sol";
import {Token42} from "./Token42.sol";
import {Token42Multisig} from "./Token42Multisig.sol";

contract Token42MultisigTest is Test {
    Token42Multisig wallet;
    Token42 token;

    // Fake addresses used only in local tests.
    address alice = address(0xA11CE);
    address bob = address(0xB0B);
    address charlie = address(0xCAFE);
    address recipient = address(0xBEEF);

    // Runs before each test, giving every test a fresh contract.
    function setUp() public {
        token = new Token42();
        address[3] memory owners = [alice, bob, charlie];
        wallet = new Token42Multisig(address(token), owners);
        token.transfer(address(wallet), 100 ether);
    }

    function test_InitialSigners() public view {
        assertEq(wallet.signers(0), alice);
        assertEq(wallet.signers(1), bob);
        assertEq(wallet.signers(2), charlie);

        assertTrue(wallet.isSigner(alice));
        assertTrue(wallet.isSigner(bob));
        assertTrue(wallet.isSigner(charlie));

        assertFalse(wallet.isSigner(address(0xBAD)));
        assertEq(wallet.REQUIRED_APPROVALS(), 2);
    }

    function test_RejectZeroSigner() public {
        address[3] memory owners = [alice, address(0), charlie];

        vm.expectRevert(bytes("Invalid signer"));
        new Token42Multisig(address(token), owners);
    }

    function test_RejectDuplicateSigner() public {
        address[3] memory owners = [alice, bob, alice];

        vm.expectRevert(bytes("Duplicate signer"));
        new Token42Multisig(address(token), owners);
    }

    function test_ProposeTransfer() public {
        uint256 amount = 10 * 10 ** 18;

        // Alice is authorized to create a proposal.
        vm.prank(alice);
        uint256 id = wallet.proposeTransfer(recipient, amount);

        // Check that all proposal details were saved correctly.
        (
            address savedRecipient,
            uint256 savedAmount,
            uint256 approvals,
            bool executed
        ) = wallet.transactions(id);

        assertEq(id, 0);
        assertEq(savedRecipient, recipient);
        assertEq(savedAmount, amount);

        // Creating a proposal does not approve or execute it.
        assertEq(approvals, 0);
        assertFalse(executed);

        // The next proposal must have a separate ID.
        vm.prank(bob);
        uint256 secondId = wallet.proposeTransfer(recipient, amount);

        assertEq(secondId, 1);
    }

    function test_RejectProposalFromNonSigner() public {
        vm.prank(address(0xBAD));
        vm.expectRevert(bytes("Not a signer"));
        wallet.proposeTransfer(recipient, 10 * 10 ** 18);
    }

    function test_RejectZeroRecipient() public {
        vm.prank(alice);
        vm.expectRevert(bytes("Invalid recipient"));
        wallet.proposeTransfer(address(0), 10 * 10 ** 18);
    }

    function test_RejectSelfRecipient() public {
        vm.prank(alice);
        vm.expectRevert(bytes("Cannot send to self"));
        wallet.proposeTransfer(address(wallet), 10 * 10 ** 18);
    }

    function test_RejectZeroAmount() public {
        vm.prank(alice);
        vm.expectRevert(bytes("Invalid amount"));
        wallet.proposeTransfer(recipient, 0);
    }

    function propose(uint256 amount) internal returns (uint256) {
        vm.prank(alice);
        return wallet.proposeTransfer(recipient, amount);
    }

    function approveTwo(uint256 id) internal {
        vm.prank(alice);
        wallet.approveTransaction(id);
        vm.prank(bob);
        wallet.approveTransaction(id);
    }

    function test_RejectInvalidToken() public {
        address[3] memory owners = [alice, bob, charlie];
        vm.expectRevert(bytes("Invalid token"));
        new Token42Multisig(address(0), owners);
    }

    function test_TwoApprovalsExecuteAndPreventReplay() public {
        uint256 id = propose(10 ether);
        approveTwo(id);
        assertEq(token.balanceOf(recipient), 0);
        vm.prank(charlie);
        wallet.executeTransaction(id);
        assertEq(token.balanceOf(recipient), 10 ether);
        assertEq(token.balanceOf(address(wallet)), 90 ether);
        assertEq(token.totalSupply(), 1_000_000 ether);
        (,,, bool executed) = wallet.transactions(id);
        assertTrue(executed);
        vm.prank(alice);
        vm.expectRevert(bytes("Already executed"));
        wallet.executeTransaction(id);
        vm.prank(bob);
        vm.expectRevert(bytes("Already executed"));
        wallet.revokeApproval(id);
        vm.prank(charlie);
        vm.expectRevert(bytes("Already executed"));
        wallet.approveTransaction(id);
    }

    function test_OneApprovalCannotExecuteOrCountTwice() public {
        uint256 id = propose(10 ether);
        vm.startPrank(alice);
        vm.expectRevert(bytes("Not enough approvals"));
        wallet.executeTransaction(id);
        wallet.approveTransaction(id);
        vm.expectRevert(bytes("Already approved"));
        wallet.approveTransaction(id);
        vm.expectRevert(bytes("Not enough approvals"));
        wallet.executeTransaction(id);
        vm.stopPrank();
        assertEq(token.balanceOf(address(wallet)), 100 ether);
    }

    function test_OutsiderCannotApproveRevokeOrExecute() public {
        uint256 id = propose(10 ether);
        approveTwo(id);
        vm.startPrank(recipient);
        vm.expectRevert(bytes("Not a signer"));
        wallet.approveTransaction(id);
        vm.expectRevert(bytes("Not a signer"));
        wallet.revokeApproval(id);
        vm.expectRevert(bytes("Not a signer"));
        wallet.executeTransaction(id);
        vm.stopPrank();
    }

    function test_RevokeAndReapprove() public {
        uint256 id = propose(10 ether);
        approveTwo(id);
        vm.startPrank(bob);
        wallet.revokeApproval(id);
        assertFalse(wallet.hasApproved(id, bob));
        vm.expectRevert(bytes("Not approved"));
        wallet.revokeApproval(id);
        vm.expectRevert(bytes("Not enough approvals"));
        wallet.executeTransaction(id);
        wallet.approveTransaction(id);
        wallet.executeTransaction(id);
        vm.stopPrank();
        assertEq(token.balanceOf(recipient), 10 ether);
    }

    function test_InvalidProposalIds() public {
        vm.startPrank(alice);
        vm.expectRevert(bytes("Invalid transaction"));
        wallet.approveTransaction(0);
        vm.expectRevert(bytes("Invalid transaction"));
        wallet.revokeApproval(0);
        vm.expectRevert(bytes("Invalid transaction"));
        wallet.executeTransaction(0);
        vm.stopPrank();
    }

    function test_ApprovalsAreSeparateForEachProposal() public {
        uint256 first = propose(10 ether);
        uint256 second = propose(20 ether);
        approveTwo(first);
        assertEq(wallet.transactionCount(), 2);
        assertFalse(wallet.hasApproved(second, alice));
        vm.prank(alice);
        vm.expectRevert(bytes("Not enough approvals"));
        wallet.executeTransaction(second);
    }

    function test_FailedTransferCanBeRetriedAfterFunding() public {
        uint256 id = propose(101 ether);
        approveTwo(id);
        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSignature(
            "ERC20InsufficientBalance(address,uint256,uint256)",
            address(wallet), 100 ether, 101 ether
        ));
        wallet.executeTransaction(id);
        (,,, bool executed) = wallet.transactions(id);
        assertFalse(executed);
        token.transfer(address(wallet), 1 ether);
        vm.prank(alice);
        wallet.executeTransaction(id);
        assertEq(token.balanceOf(recipient), 101 ether);
    }
}
