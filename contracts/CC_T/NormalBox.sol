// SPDX-License-Identifier: MIT

// pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "./ERC721/SafeMath.sol";
import "./ERC721/Context.sol";
import "./ERC721/Ownable.sol";
import "./ERC721/MinterRole.sol";
import "./ERC721/Pausable.sol";
import "./ERC721/ERC721.sol";
import "./library/ECDSA.sol";
import "./library/ReentrancyGuard.sol";

// standard interface of IERC20 token
// using this in this contract to receive Bino token by "transferFrom" method
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

library Counters {
    using SafeMath for uint256;

    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        // The {SafeMath} overflow check can be skipped here, see the comment at the top
        counter._value += 1;
    }

    function decrement(Counter storage counter) internal {
        counter._value = counter._value.sub(1);
    }
}

//盲盒NFT
contract DracooBox is Context, Ownable, MinterRole, Pausable, ERC721, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Counters for Counters.Counter;

    IERC20 public busd;

    uint256 public constant CAP = 10000;
    uint256 public constant PRICE = 200 * 1e18;   // 200 BUSD
    uint256 public maxPerAddress = 3;

    bool public saleIsActive;
    Counters.Counter private _currentId;
    uint256 private _totalSold = 0;
    mapping(address => uint256) private _boughtNum;
    address private _validator;

    event BuyNormalBox(address indexed to, uint256 indexed mintIndex);


    constructor(address busdAddress) ERC721("Dracoo Box", "DracooBox") public {
        saleIsActive = false;
        busd = IERC20(busdAddress);
        _validator = 0x103602210f3663Cf124BAd5D6253E3F701d5D577;
    }

    function setSaleIsActive(bool newState) public onlyOwner {
        saleIsActive = newState;
    }

    function setValidator(address newValidator) public onlyOwner {
        _validator = newValidator;
    }

    function checkCurrentRoundRemaining() public view returns (uint256) {
        require(saleIsActive, "this round sale does not start yet");
        return CAP.sub(_totalSold);
    }

    function checkRemainingAmounts(address account) public view returns (uint256) {
        return maxPerAddress.sub(_boughtNum[account]);
    }
    //预定购买
    function mintbyMinter(address to, uint256 amounts) public onlyMinter {
        require(_totalSold.add(amounts) <= CAP, "can only mint 10000 boxes!");
        
        _totalSold = _totalSold.add(amounts);
        for(uint256 i = 0; i < amounts; ++i) {
            _currentId.increment();
            uint256 mintIndex = _currentId.current();

            _safeMint(to, mintIndex);

            emit BuyNormalBox(to, mintIndex);
        }
    }

    // start from tokenId = 1
    // BUSD must approve first
    //购买盲盒
    function buyNormalBox(uint256 amounts, bytes calldata signature) public nonReentrant{
        require(_msgSender() == tx.origin, "contract can not buy");
        require(saleIsActive, "sale does not start yet");
        require(amounts.add(_boughtNum[_msgSender()]) <= maxPerAddress, "can not exceed purchase limits");
        require(_totalSold.add(amounts) <= CAP, "can not exceed max cap");
        require(amounts.mul(PRICE) <= busd.balanceOf(_msgSender()), "BUSD value sent is not enough");

        // check signature
        address signer = tryRecover(whitelistHash(_msgSender()), signature);
        require(signer == _validator, "check signature error: you are not on the whitelist");

        _boughtNum[_msgSender()] = _boughtNum[_msgSender()].add(amounts);
        _totalSold = _totalSold.add(amounts);
        busd.safeTransferFrom(_msgSender(), address(this), amounts.mul(PRICE));

        for(uint256 i = 0; i < amounts; ++i) {
            _currentId.increment();
            uint256 mintIndex = _currentId.current();

            _safeMint(_msgSender(), mintIndex);

            emit BuyNormalBox(_msgSender(), mintIndex);
        }

    }

    function burn(uint256 tokenId) public virtual {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721Burnable: caller is not owner nor approved");
        _burn(tokenId);
    } 

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function setBaseURI(string memory baseURI) public onlyOwner {
        _setBaseURI(baseURI);
    }

    function setTokenURI(uint256 tokenId, string memory tokenURI) public onlyOwner {
        _setTokenURI(tokenId, tokenURI);
    }

    function withdrawBUSD(address to) public onlyOwner {
        uint256 balance = busd.balanceOf(address(this));
        busd.safeTransfer(to, balance);
    }

    function whitelistHash(address account) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(account));
    }

    function tryRecover(bytes32 hashCode, bytes memory signature) public pure returns (address) {
        return ECDSA.recover(hashCode, signature);
    }

    /**
     * @dev See {ERC721-_beforeTokenTransfer}.
     *
     * Requirements:
     *
     * - the contract must not be paused.
     */
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        require(!paused(), "ERC721Pausable: token transfer while paused");
    }

}