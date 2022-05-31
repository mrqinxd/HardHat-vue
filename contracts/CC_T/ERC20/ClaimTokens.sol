// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "./IERC20.sol";
import "./SafeMath.sol";
import "./SafeERC20.sol";
import "./Context.sol";


/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}


contract ClaimTokens is Context, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    uint256 public immutable oneDay = 86400;  // 24*60*60
    uint256 public immutable draAmounts = 10 * 1e18;
    uint256 public immutable basAmounts = 1400 * 1e18;
    IERC20 public dra;
    IERC20 public bas;

    mapping(address => uint256) private _nextDRAClaimTimestamp;
    mapping(address => uint256) private _nextBASClaimTimestamp;

    event ClaimDRA(address indexed account, uint256 amounts, uint256 timestamp);
    event ClaimBAS(address indexed account, uint256 amounts, uint256 timestamp);

    constructor (address _dra, address _bas) public {
        dra = IERC20(_dra);
        bas = IERC20(_bas);
    }

    function nextDRAClaimTimestamp(address account) public view returns (uint256) {
        if (_nextDRAClaimTimestamp[account] == 0) {
            return block.timestamp.div(oneDay).mul(oneDay);
        } else {
            return _nextDRAClaimTimestamp[account];
        }
    }

    function nextBASClaimTimestamp(address account) public view returns (uint256) {
        if (_nextBASClaimTimestamp[account] == 0) {
            return block.timestamp.div(oneDay).mul(oneDay);
        } else {
            return _nextBASClaimTimestamp[account];
        }
    }

    function claimDRA() public nonReentrant {
        require(block.timestamp >= nextDRAClaimTimestamp(_msgSender()), "invalid time, try after UTC-0");

        _nextDRAClaimTimestamp[_msgSender()] = (block.timestamp.div(oneDay).add(1)).mul(oneDay);
        dra.safeTransfer(_msgSender(), draAmounts);

        emit ClaimDRA(_msgSender(), draAmounts, block.timestamp);
    }

    function claimBAS() public nonReentrant {
        require(block.timestamp >= nextBASClaimTimestamp(_msgSender()), "invalid time, try after UTC-0");

        _nextBASClaimTimestamp[_msgSender()] = (block.timestamp.div(oneDay).add(1)).mul(oneDay);
        bas.safeTransfer(_msgSender(), basAmounts);

        emit ClaimBAS(_msgSender(), basAmounts, block.timestamp);
    }

}