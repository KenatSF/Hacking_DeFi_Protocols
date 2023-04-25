// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.0;


interface IReplica {
    function update(bytes32 _oldRoot,bytes32 _newRoot,bytes memory _signature) external ;
    function proveAndProcess(bytes memory _message,bytes32[32] calldata _proof,uint256 _index) external ;
    function process(bytes memory _message) external returns (bool _success) ;
    function acceptableRoot(bytes32 _root) external view returns (bool) ;
    function prove(bytes32 _leaf,bytes32[32] calldata _proof,uint256 _index) external returns (bool) ;
    function homeDomainHash() external view returns (bytes32) ;
}