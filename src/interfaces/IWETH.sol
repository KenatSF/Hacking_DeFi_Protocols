// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IWETH {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function deposit() external payable;
    function withdraw(uint) external;
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}