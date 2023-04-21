// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IAnyswapV5ERC20 {


    function owner() external view returns (address);

    function mpc() external view returns (address);

    function Swapout(uint256 amount, address bindaddr) external returns (bool);

    function totalSupply() external view returns (uint256);

    function depositWithPermit(     address target,     uint256 value,      uint256 deadline,   uint8 v,    bytes32 r,      bytes32 s,      address to) external returns (uint)     ;

    function depositWithTransferPermit(address target, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s, address to) external returns (uint);

    function deposit() external returns (uint);

    function deposit(uint amount) external returns (uint);

    function deposit(uint amount, address to) external returns (uint);

    function withdraw() external returns (uint);

    function withdraw(uint amount) external returns (uint);

    function withdraw(uint amount, address to) external returns (uint);

    function approve(address spender, uint256 value) external returns (bool);

    function approveAndCall(address spender, uint256 value, bytes calldata data) external returns (bool);

    function permit(    address target,     address spender,    uint256 value,  uint256 deadline,   uint8 v, bytes32 r, bytes32 s) external     ;

    function transferWithPermit(address target, address to, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function transferAndCall(address to, uint value, bytes calldata data) external returns (bool);

}