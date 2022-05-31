// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

interface IProfileNFT {

    function safeMint(address to, uint256 classId) external returns (uint256);

    function burn(uint256 tokenId) external;
    
}