// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract PledgeEarn is Ownable {
    address public _mtgTokenContract;

    function setTknAdr(address tknAdr_) public {
        _mtgTokenContract = tknAdr_;
    }

    //存  a>>zy
    function transTestMtgToken(address from,uint TknAmout_) external {
        uint mtgCount = TknAmout_;

        IERC20(_mtgTokenContract).transferFrom(from, address(this), mtgCount);
    }

    //取  zy>>a
    function transFormTestMtg(address to,uint TknAmout_) external {
        uint mtgCount = TknAmout_;
        IERC20(_mtgTokenContract).approve(address(this), mtgCount);

        IERC20(_mtgTokenContract).transferFrom(address(this),to, mtgCount);
    }    
}