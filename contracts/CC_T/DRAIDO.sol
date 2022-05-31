// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "./ERC20/SafeMath.sol";
import "./ERC20/Address.sol";
import "./ERC20/Context.sol";
import "./ERC20/Ownable.sol";
import "./ERC20/IERC20.sol";
import "./ERC20/SafeERC20.sol";
import "./library/ReentrancyGuard.sol";
import "./library/ECDSA.sol";

//DRA购买代币合约
contract DRAIDO is Context, Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 public draToken;
    IERC20 public buyToken;
    uint256 public price;        // e.g. 0.1 BUSD/DRA, deciaml = 18
    uint256 public decimal = 1 * 1e18;
    address private _validator;
    bool private _isStart = false;

    mapping(address => bool) private _isBought;

    event BuyDRA(address indexed account, uint256 indexed amounts);

    constructor (address _draToken, 
                 address _buyToken, 
                 address _newValidator, 
                 uint256 _defaultPrice) public {

        draToken = IERC20(_draToken);
        buyToken = IERC20(_buyToken);
        _validator = _newValidator;
        price = _defaultPrice;  // _defaultPrice = 1 * 1e17
    }

    modifier validTime() {
        require(_isStart, "IDO is not open NOW");
        _;
    }

    function changeState(bool _newState) public onlyOwner {
        _isStart = _newState;
    }

    function changePrice(uint256 _newPrice) public onlyOwner {
        price = _newPrice;
    }

    function changeNewValidator(address _newValidator) public onlyOwner {
        _validator = _newValidator;
    }

    function recoverToken(address token, address to) public onlyOwner {
        uint256 balance = IERC20(token).balanceOf(address(this));
        IERC20(token).safeTransfer(to, balance);
    }

    function isBought(address account) public view returns (bool) {
        return _isBought[account];
    }

    // buyToken must "approve" this contract as spender
    // amounts: decimal = 18
    //购买DRA 向本合约打钱 然后合约给他发代币
    function buyDRA(uint256 amounts, bytes memory signature) public nonReentrant validTime {
        require(!_isBought[_msgSender()], "you can NOT bought again");
        require(amounts <= draToken.balanceOf(address(this)), "not enought DRA balance in this contract");
        address signer = recoveredSigner(signature, _calculateHash(_msgSender(), amounts));
        require(signer == _validator, "you are not valid to buy");

        _isBought[_msgSender()] = true;
        uint256 totalPrice = price.mul(amounts).div(decimal);
        require(totalPrice <= buyToken.balanceOf(_msgSender()), "you do not have enough balance to buy");
        buyToken.safeTransferFrom(_msgSender(), address(this), totalPrice);
        draToken.safeTransfer(_msgSender(), amounts);

        emit BuyDRA(_msgSender(), amounts);
    }

    function _calculateHash(address account, uint256 amounts) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(account, amounts));
    }

    function recoveredSigner(bytes memory signature, bytes32 hashCode) public pure returns (address) {
        return ECDSA.recover(hashCode, signature);
    }

}