// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "./SafeMath.sol";
import "./Context.sol";

interface IDracooMaster {
    
    function safeMint(address to) external returns (uint256);

}

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

contract ClaimDracooTestnet is Context, ReentrancyGuard {
    using SafeMath for uint256;

    uint256 public immutable oneDay = 86400;  // 24*60*60
    IDracooMaster public dracoo;

    mapping(address => uint256) private _nextClaimTimestamp;

    event ClaimDracoo(address indexed account, uint256 tokenId, uint256 timestamp);

    constructor (address _dracoo) public {
        dracoo = IDracooMaster(_dracoo);
    }

    function nextClaimTimestamp(address account) public view returns (uint256) {
        if (_nextClaimTimestamp[account] == 0) {
            return block.timestamp.div(oneDay).mul(oneDay);
        } else {
            return _nextClaimTimestamp[account];
        }
    }

    function claimDracoo() public nonReentrant {
        require(block.timestamp >= nextClaimTimestamp(_msgSender()), "invalid time, try after UTC-0");

        if (_nextClaimTimestamp[_msgSender()] == 0) {
            for (uint i = 0; i < 3; ++i) {
                uint256 tokenId = dracoo.safeMint(_msgSender());

                emit ClaimDracoo(_msgSender(), tokenId, block.timestamp);
            }
        } else {
            uint256 tokenId = dracoo.safeMint(_msgSender());
            emit ClaimDracoo(_msgSender(), tokenId, block.timestamp);
        }

        _nextClaimTimestamp[_msgSender()] = (block.timestamp.div(oneDay).add(1)).mul(oneDay);
    }

}
