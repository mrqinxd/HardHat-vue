// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;


import "@openzeppelin/contracts/access/Ownable.sol";

contract BinBoxN is Ownable{

    mapping(uint256=>uint256) public BoxNumber;
    mapping(address=>uint256[]) public BOXAddr;
    mapping(address=>uint256) public NFT;
    bool isOpen = false;
    uint256 tokenID=0;
    uint256 BOXID = 0;

    constructor(){       
    }

    //获取随机数
    function rand(uint256 _length) public view returns(uint256) {
        uint256 random = uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp)));
        return random%_length;
    }

    //根据概率返回开盒数量
    function getBoxNumber() public view returns(uint256){
        uint256 randNum = rand(100);
        //5% 3
        if(randNum>0 && randNum <= 5){
            return 3;
        }else if(randNum >5 && randNum <=15){
            return 2;
        }else{
            return 1;
        }
    }

    //购买盲盒
    function mintBOx(uint256 amounts) public {
        //一些盲盒限制
        for(uint256 i=0;i<amounts;i++){
            uint256 num = getBoxNumber();
            BOXID += 1;
            BoxNumber[BOXID] = num;
            BOXAddr[msg.sender].push(BOXID);
        }
    }

    //打开盲盒
    function openBOx(uint256 BID) public {
        //判定地址下是否存在这个boxid
        bool isTrue = AddrHasBox(msg.sender,BID);
        if(isTrue){
            //打开盲盒|一个盲盒可能有多个NFT
            for(uint256 b=0;b<BoxNumber[BID];b++){
                tokenID += 1;
                NFT[msg.sender] = tokenID;
            }
        }
    }

    function AddrHasBox(address addr,uint256 BID)public view returns(bool){
        if(BOXAddr[addr].length > 0){
            for(uint256 i=0;i<BOXAddr[addr].length;i++){
                if(BOXAddr[addr][i] == BID){
                    return true;
                }
            }
            return false;
        }
        return false;        
    }
}