// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;
/// * MTG Version 1st. to test, 10Mar.2022

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract phase is ERC20,Ownable{
    uint256 totalTokens;
    uint256 public ratio = 50;
    uint256 startTime;
    uint256[] public ratioConfig;

    mapping(address=>uint256) public ActiveBalance;

    constructor() ERC20("Phase", "PAT") {
        totalTokens = 100000 * (10**uint256(decimals()));
        _mint(owner(), totalTokens);
        startTime = block.timestamp;
    }

    //方式一 根据占比计算出允许交易金额【递增】
    function setRatio(uint newRatio) public onlyOwner{
        ratio = newRatio;
    }

    function getRatioAmount() public view returns(uint256){
        uint256 poor= block.timestamp - startTime;
        return (poor*ratio)/100;
    }

    //方式二 根据配置规则计算允许交易金额【规则】
    function setRaioConfig(uint256[] calldata newConfig) public onlyOwner{
        ratioConfig = newConfig;
    }

    function getRatioAmountForConfig() public view returns(uint256){
        uint256 poor= (block.timestamp - startTime)/86400;
        return ratioConfig[poor];
    }

    //交易开始之前控制可用交易金额
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override virtual {
        if(from != address(0)){
            require(ActiveBalance[from] > amount,"Phase to low");
            //可以加其他限制条件
            ActiveBalance[from] = getRatioAmount();
        }
    }

    //交易结束扣除可用金额
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override virtual {
        if(from != address(0)){
            //可以加其他限制条件
            if(amount > ActiveBalance[from]){
                ActiveBalance[from] = 0;
            }else{
                ActiveBalance[from] -= amount;
            }            
        }
    }
}