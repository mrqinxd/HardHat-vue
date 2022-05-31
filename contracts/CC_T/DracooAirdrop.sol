// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import "./ERC721/Ownable.sol";

//规定接口方法
interface IDracooMaster {
    //指定用户mint
    function safeMint(address to) external returns (uint256);
    //指定用户 指定nft品种mint
    function breedMint(address to, uint256[2] memory parentsId) external returns (uint256);

}

//部署空投合约
contract DracooAirdrop is Ownable {
    //nft合约地址
    IDracooMaster private _dracoo;
    //默认部署时加入
    constructor (address dracooAddress) public {
        _dracoo = IDracooMaster(dracooAddress);
    }   
    //空投nft
    function airdrop(address to, uint256 amounts) public onlyOwner {
        
        for (uint256 i = 0; i < amounts; ++i) {
            _dracoo.safeMint(to);
        }

    }
    //空投指定nft
    function breedMintAirdrop(address to, uint256[2] memory parentsId) public onlyOwner {
        _dracoo.breedMint(to, parentsId);
    }
}