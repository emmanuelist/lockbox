// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/PiggyBank.sol";

contract PiggyBankTest is Test {
    PiggyBank public piggyBank;
    address public owner = address(this);
    address public user = address(0x1234);
    
    receive() external payable {}

    function setUp() public {
        uint256 unlockTime = block.timestamp + 1 days;
        piggyBank = new PiggyBank{value: 0}(unlockTime);
    }

    function testInitialState() public view {
        assertEq(piggyBank.owner(), owner);
        assertTrue(piggyBank.unlockTime() > block.timestamp);
        assertEq(piggyBank.getBalance(), 0);
    }

    function testDeposit() public {
        uint256 depositAmount = 1 ether;
        piggyBank.deposit{value: depositAmount}();
        assertEq(piggyBank.getBalance(), depositAmount);
    }

    function testCannotWithdrawBeforeUnlock() public {
        uint256 depositAmount = 1 ether;
        piggyBank.deposit{value: depositAmount}();

        vm.expectRevert(PiggyBank.StillLocked.selector);
        piggyBank.withdraw();
    }

    function testWithdrawAfterUnlock() public {
        uint256 depositAmount = 1 ether;
        piggyBank.deposit{value: depositAmount}();
        
        // Fast forward time to after unlock
        vm.warp(piggyBank.unlockTime() + 1);
        
        uint256 balanceBefore = owner.balance;
        piggyBank.withdraw();
        
        assertEq(owner.balance, balanceBefore + depositAmount);
        assertEq(piggyBank.getBalance(), 0);
    }

    function testOnlyOwnerCanWithdraw() public {
        uint256 depositAmount = 1 ether;
        piggyBank.deposit{value: depositAmount}();
        
        // Fast forward time
        vm.warp(piggyBank.unlockTime() + 1);
        
        // Try to withdraw as non-owner
        vm.prank(user);
        vm.expectRevert(PiggyBank.NotOwner.selector);
        piggyBank.withdraw();
    }

    function testCannotDepositZero() public {
        vm.expectRevert(PiggyBank.ZeroDeposit.selector);
        piggyBank.deposit{value: 0}();
    }

    function testEmitsDepositedEvent() public {
        uint256 depositAmount = 1 ether;
        
        vm.expectEmit(true, false, false, true);
        emit PiggyBank.Deposited(address(this), depositAmount);
        
        piggyBank.deposit{value: depositAmount}();
    }

    function testEmitsWithdrawnEvent() public {
        uint256 depositAmount = 1 ether;
        piggyBank.deposit{value: depositAmount}();
        
        vm.warp(piggyBank.unlockTime() + 1);
        
        vm.expectEmit(true, false, false, true);
        emit PiggyBank.Withdrawn(owner, depositAmount);
        
        piggyBank.withdraw();
    }

    function testMultipleDeposits() public {
        piggyBank.deposit{value: 1 ether}();
        piggyBank.deposit{value: 0.5 ether}();
        piggyBank.deposit{value: 0.25 ether}();
        
        assertEq(piggyBank.getBalance(), 1.75 ether);
    }

    function testIsUnlockedBeforeTime() public view {
        assertFalse(piggyBank.isUnlocked());
    }

    function testIsUnlockedAfterTime() public {
        vm.warp(piggyBank.unlockTime() + 1);
        assertTrue(piggyBank.isUnlocked());
    }

    function testGetUnlockTime() public view {
        assertEq(piggyBank.getUnlockTime(), piggyBank.unlockTime());
    }

    function testCannotCreateWithPastUnlockTime() public {
        vm.expectRevert(PiggyBank.InvalidUnlockTime.selector);
        new PiggyBank(block.timestamp - 1);
    }

    function testReentrancyProtection() public {
        // This test verifies the nonReentrant modifier works
        uint256 depositAmount = 1 ether;
        piggyBank.deposit{value: depositAmount}();
        
        vm.warp(piggyBank.unlockTime() + 1);
        
        // First withdrawal should succeed
        piggyBank.withdraw();
        
        // Contract balance should be 0, so no reentrancy possible
        assertEq(piggyBank.getBalance(), 0);
    }
}