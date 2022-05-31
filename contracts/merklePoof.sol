//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract Merkle is Ownable {
    bytes32 public saleMerkleRoot;
    
    mapping(address => bool) public claimed;
    //设置跟root
    function setSaleMerkleRoot(bytes32 merkleRoot) external onlyOwner {
        saleMerkleRoot = merkleRoot;
    }
    //验证器 是否处于白名单
    modifier isValidMerkleProof(bytes32[] calldata merkleProof, bytes32 root) {
        require(
            MerkleProof.verify(
                merkleProof,
                root,
                keccak256(abi.encodePacked(msg.sender))
            ),
            "Address does not exist in list"
        );
        _;
    }
    //逻辑操作
    function mint(bytes32[] calldata merkleProof)
        external
        isValidMerkleProof(merkleProof, saleMerkleRoot)
    {
        require(!claimed[msg.sender], "Address already claimed");
        claimed[msg.sender] = true;
    }
}