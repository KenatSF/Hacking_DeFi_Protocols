// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IMRC20 {
    function balanceOf(address account) external view returns (uint256);    
    function owner() external view returns (address);
    function isOwner() external view returns (bool);
    function getTokenTransferOrderHash(address spender,uint256 tokenIdOrAmount,bytes32 data,uint256 expiration) external view returns (bytes32 orderHash);
    function transferWithSig(bytes calldata sig,uint256 amount,bytes32 data,uint256 expiration,address to) external returns (address from);
    function setParent(address) external  ;
    function withdraw(uint256 amount) external payable  ;
    function name() external pure returns (string memory) ;
    function symbol() external pure returns (string memory) ;
    function decimals() external pure returns (uint8) ;
    function totalSupply() external view returns (uint256) ;
    function transfer(address to, uint256 value) external payable returns (bool) ;
}