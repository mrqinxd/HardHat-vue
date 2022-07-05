// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "./CC/ERC20/SafeMath.sol";
import "./CC/ERC20/Address.sol";
import "./CC/ERC20/Ownable.sol";
import "./CC/ERC20/IERC20.sol";
import "./CC/ERC20/SafeERC20.sol";


//DRA购买代币合约
contract DRAIDO is  Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 public draToken;

    constructor (address _draToken) public {
        draToken = IERC20(_draToken);        
    }

    //购买DRA 向本合约打钱 然后合约给他发代币
    function buyDRA(uint256 amounts) public {
        draToken.safeTransfer(_msgSender(), amounts);
    }
}

contract TestHash{
    //散列随机数的范围，此处为6，表明最终的随机数范围 [1,6]
    uint constant public TOKEN_LIMIT = 6;
    //散列数组，用于解决随机时出现重复数值的情况
    uint[TOKEN_LIMIT] public indices;
    //该方法被调用了多少次，等于已经产生的随机数数量。
    uint nonce;
    function randomIndex() public returns (uint) {
        uint totalSize = TOKEN_LIMIT - nonce;
        uint index = uint(keccak256(abi.encodePacked(nonce, msg.sender, block.difficulty, block.timestamp))) % totalSize;
        uint value = 0;
        if (indices[index] != 0) {
            value = indices[index];
        } else {
            value = index;
        }
 
        // Move last value to selected position
        if (indices[totalSize - 1] == 0) {
            // Array position not initialized, so use position
            indices[index] = totalSize - 1;
        } else {
            // Array position holds a value so use that
            indices[index] = indices[totalSize - 1];
        }
        nonce++;
        // Don't allow a zero index, start counting at 1
        return value+1;
    }
}