//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract MTWToken is ERC721Enumerable,Ownable{
    using Strings for uint256;
    //开关
    bool public _revealed = false;
    // Constants
    uint256 public constant MAX_SUPPLY = 15;
    uint256 public minPrice = 0.01 ether;
    uint256 public maxBalance = 10;//单个持有
    uint256 public maxMint = 3;
    string BaseURI;
    string public NotRevealedURI;
    string public Extension = ".json";

    mapping(uint256=>string) private _tokenURIs;

    constructor(string memory initBaseURI,string memory initNotRevealedURI) ERC721("MTW Token","MTW"){
        BaseURI = initBaseURI;
        NotRevealedURI = initNotRevealedURI;
    }
    //购买MTW
    function mintMTW(uint256 Quantity) public payable{
        require(totalSupply()+Quantity <= MAX_SUPPLY,"MAX_SUPPLY");
        require(balanceOf(msg.sender) + Quantity <= maxBalance,"Max Balance");
        require(Quantity * minPrice >= msg.value,"balance to loo");
        require(Quantity <= maxMint,"mint only 3");

        for(uint256 i = 0;i<Quantity;i++){
            uint256 mintIndex = totalSupply();
            if(totalSupply() < MAX_SUPPLY){
                _safeMint(msg.sender,mintIndex);
            }
        }

    }
    //根据tokenID返回NFT地址
    function tokenURI(uint256 tokenId) public view virtual override returns(string memory){
        require(_exists(tokenId),"ERC721:tokenId noExistent");
        
        if(_revealed == false){
            return NotRevealedURI;
        }

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();

        if(bytes(base).length == 0){
            return _tokenURI;
        }
        if(bytes(_tokenURI).length > 0){
            return string(abi.encodePacked(base,_tokenURI));
        }
        return string(abi.encodePacked(base,tokenId.toString(),Extension));
    }
    //返回NFT公告地址
    function _baseURI()internal view  virtual override returns(string memory){
        return BaseURI;
    }
    //盲合状态开关
    function changeRevel() public onlyOwner{
        _revealed = !_revealed;
    }
    //设置单价
    function setPrice(uint256 newPrice) public onlyOwner{
        minPrice = newPrice;
    }
    //设置公告NFT【盲合未开启】地址
    function setNotRevealedURI(string memory newNotRevealeURI) public onlyOwner{
        NotRevealedURI = newNotRevealeURI;
    }
    //设置NFT地址
    function setBaseURI(string memory newBaseURI) public onlyOwner{
        BaseURI = newBaseURI;
    }
    //设置单个地址最大持有
    function setMaxBalance(uint256 newMaxBalance) public onlyOwner{
        maxBalance = newMaxBalance;
    }
    //设置单次最大购买
    function setMaxMint(uint256 newMaxMint) public onlyOwner{
        maxMint = newMaxMint;
    }

    //取回NFT所赚的钱
    function withdraw(address to) public onlyOwner{
        uint256 balance = address(this).balance;
        payable(to).transfer(balance);
    }
}