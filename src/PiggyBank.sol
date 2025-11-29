// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title PiggyBank
 * @notice A time-locked savings contract for disciplined ETH deposits
 * @dev Users can deposit ETH and withdraw only after a specified unlock time
 */
contract PiggyBank {
    // Custom errors for gas optimization
    error StillLocked();
    error NotOwner();
    error ZeroDeposit();
    error TransferFailed();
    error InvalidUnlockTime();

    address public immutable owner;
    uint256 public immutable unlockTime;

    // Reentrancy guard
    bool private locked;

    event Deposited(address indexed depositor, uint256 amount);
    event Withdrawn(address indexed withdrawer, uint256 amount);

    modifier nonReentrant() {
        require(!locked, "ReentrancyGuard: reentrant call");
        locked = true;
        _;
        locked = false;
    }

    constructor(uint256 _unlockTime) payable {
        if (_unlockTime <= block.timestamp) revert InvalidUnlockTime();
        owner = msg.sender;
        unlockTime = _unlockTime;
    }

    function deposit() external payable {
        if (msg.value == 0) revert ZeroDeposit();
        emit Deposited(msg.sender, msg.value);
    }

    function withdraw() external nonReentrant {
        if (block.timestamp < unlockTime) revert StillLocked();
        if (msg.sender != owner) revert NotOwner();
        
        uint256 amount = address(this).balance;
        emit Withdrawn(msg.sender, amount);
        
        (bool success, ) = payable(owner).call{value: amount}("");
        if (!success) revert TransferFailed();
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function getUnlockTime() external view returns (uint256) {
        return unlockTime;
    }

    function isUnlocked() external view returns (bool) {
        return block.timestamp >= unlockTime;
    }
}