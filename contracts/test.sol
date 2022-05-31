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