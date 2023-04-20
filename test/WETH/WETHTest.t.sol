// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "../../src/interfaces/IWETH.sol";


interface IWETH9 is IWETH {
    function permit(address target, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external payable;
    function transferWithPermit(address target, address to, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external payable returns (bool);
}


contract WETHTest is Test {
    IWETH9 public weth;

    address public constant nullAddress = address(0x00);
    address public ana;
    address public kenat;


    function setUp() public {
        vm.createSelectFork(vm.envString("FOUNDRY_INFURA"));
        weth = IWETH9(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
        ana = makeAddr("userAna");
        kenat = makeAddr("userKenat");
    }


    function testWETH() public {
        console.log("Contract address: ", address(this));
        console.log(" ");

        uint256 contractBalanceInit = weth.balanceOf(address(this));
        uint256 kenatBalanceInit = weth.balanceOf(kenat);
        //console.log("Amount 0: ", _amount);
        uint256 amount = 500 ether;

        weth.deposit{value: amount}();

        // vm.prank(kenat);
        // weth.deposit{value: 8 ether}();

        uint256 contractBalanceFin = weth.balanceOf(address(this));
        uint256 kenatBalanceFin = weth.balanceOf(kenat);

        console.log("Contract balance Init: ", contractBalanceInit);
        console.log("Kenat balance Init: ", kenatBalanceInit);
        console.log("Contract balance Fin: ", contractBalanceFin);
        console.log("Kenat balance Fin: ", kenatBalanceFin);
        console.log(" ");

    }

    


}
