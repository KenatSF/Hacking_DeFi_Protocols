pragma solidity ^0.8.13;

//   You can find the original code at: https://medium.com/immunefi/88mph-theft-of-unclaimed-mph-rewards-bugfix-review-1dec98b9956b

import "forge-std/Test.sol";
import "../../../src/PoC/PoC_Hack_d/WithFlashloan.sol";

contract PoC88MPHTest is Test {
  using stdStorage for StdStorage;

  WithFlashloan public attacker;


  function setUp() public {
    vm.createSelectFork(vm.envString("FOUNDRY_INFURA"));
  }

  function testRun()public {
    vm.rollFork(15598022); // Before the report submitted
    attacker = new WithFlashloan();
    attacker.run();
  }
}