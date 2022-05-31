// SPDX-License-Identifier: MIT

// pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "./ERC721/SafeMath.sol";
import "./ERC721/Address.sol";
import "./ERC721/Context.sol";
import "./ERC721/Ownable.sol";
import "./ERC721/ERC721.sol";
import "./ERC20/IERC20.sol";
import "./library/ECDSA.sol";
import "./library/ReentrancyGuard.sol";


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

//DRA代金券合约
contract DRAVoucher is Context, Ownable, ERC721, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Counters for Counters.Counter;

    IERC20 public busd;
    uint256 public immutable CAP = 10000;
    uint256 public immutable PRICE = 50 * 1e18;   // 50 BUSD
    // public sale max per transaction
    uint256 public maxPerTime = 1;

    bool public saleIsActive;
    // 1: Dracoo holders 2: whilelist 3: public sale
    uint256 public currentRound;
    uint256 private _totalSold = 0;
    // address => roundNum => purchased or not 
    mapping(address => mapping(uint256 => bool)) private _isRoundPurchased;
    address private _validator;
    Counters.Counter private _currentId;


    event BuyDRAVoucher(uint256 indexed roundNum, address indexed account, uint256 indexed tokenId);


    constructor (address busdAddress, address validator) ERC721("Dracoo Master IDO Voucher", "DRAVoucher") public {
        busd = IERC20(busdAddress);
        _validator = validator;

        saleIsActive = false;
        currentRound = 1;
    }

    function withdrawBUSD(address to) public onlyOwner {
        uint256 balance = busd.balanceOf(address(this));
        busd.safeTransfer(to, balance);
    }

    function setValidator(address newValidator) public onlyOwner {
        _validator = newValidator;
    }

    function setMaxPerTime(uint256 newMax) public onlyOwner {
        maxPerTime = newMax;
    }

    // Set round first, then active sale
    function setCurrentRound(uint256 roundNum) public onlyOwner {
        require(roundNum == 1 || roundNum == 2 || roundNum == 3, "roundNum must be 1, 2, or 3");
        currentRound = roundNum;
    }

    function setSaleIsActive(bool newState) public onlyOwner {
        saleIsActive = newState;
    }

    function setBaseURI(string memory baseURI) public onlyOwner {
        _setBaseURI(baseURI);
    }

    function setTokenURI(uint256 tokenId, string memory tokenURI) public onlyOwner {
        _setTokenURI(tokenId, tokenURI);
    }

    function checkRemaining() public view returns (uint256) {
        return CAP.sub(_totalSold);
    }

    function isRoundPurchased(address account, uint256 roundNum) public view returns (bool) {
        return _isRoundPurchased[account][roundNum];
    }

    // busd: approve first|总共预售三轮 但是每轮数量上限没有限制（可以通过whitelistHash来破解本函数）
    function buyPreSaleVoucher(uint256 roundNum, 
                               uint256 amounts, 
                               bytes memory signature) external nonReentrant returns(uint256[] memory) {

        require(saleIsActive, "sale does not start yet");
        require(currentRound == roundNum, "currentRound != roundNum: presale");
        require(_totalSold.add(amounts) <= CAP, "can not exceed max cap");
        require(!_isRoundPurchased[_msgSender()][roundNum], "you can only purchase ONE time in this round");
        // check signature
        address signer = tryRecover(whitelistHash(_msgSender(), roundNum, amounts), signature);
        require(signer == _validator, "signature error");

        _isRoundPurchased[_msgSender()][roundNum] = true;
        _totalSold = _totalSold.add(amounts);

        busd.safeTransferFrom(_msgSender(), address(this), amounts.mul(PRICE));

        uint256[] memory tokenIds = _mintVouchers(_msgSender(), amounts);

        return tokenIds;
    }

    // busd: approve first|公开售卖 每次购买不超过1个（可配置）
    function buyPublicSaleVoucher(uint256 amounts) external nonReentrant returns(uint256[] memory) {

        require(_msgSender() == tx.origin, "contract can not buy");
        require(saleIsActive, "sale does not start yet");
        require(currentRound == 3, "currentRound must be in Round #3: public sale");
        require(amounts <= maxPerTime, "can not excced maxPerTime limit");
        require(_totalSold.add(amounts) <= CAP, "can not exceed max cap");

        _totalSold = _totalSold.add(amounts);

        busd.safeTransferFrom(_msgSender(), address(this), amounts.mul(PRICE));

        uint256[] memory tokenIds = _mintVouchers(_msgSender(), amounts);

        return tokenIds;
    }

    function whitelistHash(address account, uint256 roundNum, uint256 amounts) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(account, roundNum, amounts));
    }

    function tryRecover(bytes32 hashCode, bytes memory signature) public pure returns (address) {
        return ECDSA.recover(hashCode, signature);
    }

    function _mintVouchers(address to, uint256 amounts) internal virtual returns(uint256[] memory) {
        
        uint256[] memory tokenIds = new uint256[](amounts);
        for (uint256 i = 0; i < amounts; ++i) {
            _currentId.increment();
            uint256 tokenId = _currentId.current();
            tokenIds[i] = tokenId;
            _safeMint(to, tokenId);

            emit BuyDRAVoucher(currentRound, to, tokenId);
        }

        return tokenIds;
    }

}