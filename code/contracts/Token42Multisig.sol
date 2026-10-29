// SPDX-License-Identifier: MIT
pragma solidity ^0.8.34;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

// A fixed 2-of-3 treasury. Only transfers of the configured token are supported.
contract Token42Multisig {
    using SafeERC20 for IERC20;

    IERC20 public immutable token;
    mapping(uint256 => mapping(address => bool)) public hasApproved;

    event TransactionApproved(uint256 indexed transactionId, address indexed signer);
    event ApprovalRevoked(uint256 indexed transactionId, address indexed signer);
    event TransactionExecuted(uint256 indexed transactionId, address indexed executor);

    // Three accounts authorized to propose and approve transfers.
    address[3] public signers;

    // Quickly check whether an account is an authorized signer.
    mapping(address => bool) public isSigner;

    // Two different signers must approve before execution.
    uint256 public constant REQUIRED_APPROVALS = 2;

    // Information stored for each proposed transfer.
    struct Transaction {
        address recipient;
        uint256 amount;
        uint256 approvals;
        bool executed;
    }

    // The array index identifies each proposal: 0, 1, 2, ...
    Transaction[] public transactions;

    // Records proposal details in the blockchain's transaction logs.
    event TransactionProposed(
        uint256 indexed transactionId,
        address indexed proposer,
        address indexed recipient,
        uint256 amount
    );

    // Restrict a function to the authorized signers.
    modifier onlySigner() {
        require(isSigner[msg.sender], "Not a signer");
        _;
    }

    constructor(address tokenAddress, address[3] memory initialSigners) {
        require(tokenAddress.code.length > 0, "Invalid token");
        token = IERC20(tokenAddress);
        for (uint256 i = 0; i < 3; i++) {
            address signer = initialSigners[i];

            require(signer != address(0), "Invalid signer");
            require(!isSigner[signer], "Duplicate signer");

            signers[i] = signer;
            isSigner[signer] = true;
        }
    }

    // Store a transfer request without moving tokens or approving it.
    // The amount is expressed in the token's smallest units.
    function proposeTransfer(
        address recipient,
        uint256 amount
    ) external onlySigner returns (uint256 transactionId) {
        require(recipient != address(0), "Invalid recipient");
        require(recipient != address(this), "Cannot send to self");
        require(amount > 0, "Invalid amount");

        // The new proposal will occupy the next available array index.
        transactionId = transactions.length;

        transactions.push(
            Transaction({
                recipient: recipient,
                amount: amount,
                approvals: 0,
                executed: false
            })
        );

        emit TransactionProposed(
            transactionId,
            msg.sender,
            recipient,
            amount
        );
    }

    // These checks run before accessing a proposal in storage.
    modifier pendingTransaction(uint256 transactionId) {
        require(transactionId < transactions.length, "Invalid transaction");
        require(!transactions[transactionId].executed, "Already executed");
        _;
    }

    function transactionCount() external view returns (uint256) {
        return transactions.length;
    }

    // Each approval is an on-chain transaction signed by the approving account.
    function approveTransaction(uint256 transactionId)
        external onlySigner pendingTransaction(transactionId)
    {
        require(!hasApproved[transactionId][msg.sender], "Already approved");
        hasApproved[transactionId][msg.sender] = true;
        transactions[transactionId].approvals += 1;
        emit TransactionApproved(transactionId, msg.sender);
    }

    // A signer may withdraw their approval until execution occurs.
    function revokeApproval(uint256 transactionId)
        external onlySigner pendingTransaction(transactionId)
    {
        require(hasApproved[transactionId][msg.sender], "Not approved");
        hasApproved[transactionId][msg.sender] = false;
        transactions[transactionId].approvals -= 1;
        emit ApprovalRevoked(transactionId, msg.sender);
    }

    function executeTransaction(uint256 transactionId)
        external onlySigner pendingTransaction(transactionId)
    {
        Transaction storage transaction = transactions[transactionId];
        require(transaction.approvals >= REQUIRED_APPROVALS, "Not enough approvals");

        // Mark executed before calling the token to prevent replay/reentry of this proposal.
        // If the transfer fails, the entire call reverts, including this flag change.
        transaction.executed = true;
        token.safeTransfer(transaction.recipient, transaction.amount);
        emit TransactionExecuted(transactionId, msg.sender);
    }
}
