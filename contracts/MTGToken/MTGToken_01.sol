// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.10;
/// * MTG Version 1st. to test, 10Mar.2022

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

/**
 * MTG Token, totalSupply 210000000
 */
contract CztToken is ERC20, ERC20Burnable, Ownable {
    event checkAddr(address);
    event checkParam(address, uint256);

    /// * Leon add game pool buffer, 13Jan.2022
    //mapping (address => uint256) public playerBet;
    //address[] betPlayers;
    uint256 totalTokens = 0;

    /** leon add constructor for initial test data, 17Jan.2022
     */
    constructor() ERC20("Cha Zia Token", "CZT") {
        totalTokens = 100000 * (10**uint256(decimals()));
        _mint(owner(), totalTokens);
    }

    function burn(uint256 _value) public override onlyOwner {
        super.burn(_value);
    }

    /// * Leon add for compiler suggestion, 12Jan.2022
    receive() external payable {}

    /// * Leon modify default fallback function:
    // Accept any incoming amount
    /// * function () public payable {}
    fallback() external payable {}

    /**
     * Leon make contract suiside
     */
    function destroy() public {
        require(msg.sender == owner(), "hacker want destroy contract!");
        selfdestruct(payable(owner())); /// * /payable
    }
}