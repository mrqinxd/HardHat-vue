// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "./ERC721/SafeMath.sol";
import "./ERC721/Address.sol";
import "./ERC721/Context.sol";
import "./ERC721/Ownable.sol";
import "./ERC721/IERC721.sol";
import "./ERC721/IERC721Receiver.sol";
import "./library/ReentrancyGuard.sol";
import "./library/ECDSA.sol";


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
//拍卖合约
contract DracooMarketAuction is Context, Ownable, IERC721Receiver, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct TransactionInput {
        uint256 transactionId;
        address seller;
        address nftAddress;
        uint256 tokenId;
        address erc20Address;
        uint256 price;              // the acution's starting price set by seller
        uint256 kind;
        uint256 salt;
        uint256 auctionEndTime;     // the initial auction end time set by seller
    }

    struct AuctionStatus {
        uint256 transactionId;
        // the current highest bidder
        address highestBidder;
        // the current highest bid price
        uint256 highestBid;
        // when auction ends, set this attribute as True
        bool ended;
        // whether the auction of current token is paused
        bool isMarketPaused;
    }

    // BNB
    address private constant BNB_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    uint32 public constant BASE = 1e6;
    uint8 private constant KIND_BUY = 2;   // 1 = fixed price, 2 = auction
    uint32 public fee;
    // signer
    address private _validator;

    // nftAddress is added to the market or not
    mapping(address => bool) private _nftAvailable;
    // erc20Address is available or not
    mapping(address => bool) private _erc20Available;
    // transactionId => bool; exist or not
    // mapping(uint256 => bool) private _isTransactionIdExists;
    // transactionId => bool; Order canceled or finished
    mapping(uint256 => bool) private _orderCanceledOrFinished;
    // nftAddress => tokenId => AuctionStatus; representing the status of every token auction
    mapping(address => mapping(uint256 => AuctionStatus)) private _auctionStatus;

    event CancelOrder(uint256 indexed transactionId, address indexed nftAddress, uint256 tokenId, address seller, address erc20Address, uint256 salePrice, uint256 auctionEndTime);
    event HighestBidIncreased(uint256 indexed transactionId, address indexed nftAddress, uint256 tokenId, uint newBidPrice);
    event AuctionEnded(uint256 indexed transactionId, address indexed nftAddress, uint256 tokenId, address seller, address buyer, address erc20Address, uint salePrice);
    
    constructor(
        address _newValidator
    ) public {
        fee = 4 * 1e4;   // 4%, 40000/1000000 = 0.04
        _erc20Available[BNB_ADDRESS] = true;
        _validator = _newValidator;
    }

    function setFee(uint32 newFee) external onlyOwner {
        fee = newFee;
    }

    function setNewValidator(address newValidator) external onlyOwner {
        _validator = newValidator;
    }

    function setAvailableNft(address nftAddress, bool newState) external onlyOwner {
        _nftAvailable[nftAddress] = newState;
    }

    function setAvailableERC20(address erc20Address, bool newState) external onlyOwner {
        _erc20Available[erc20Address] = newState;
    }
    //取回合约剩余代币余额
    function withdrawBNB(address payable to) external onlyOwner {
        uint256 balance = address(this).balance;
        to.transfer(balance);
    }

    function withdrawERC20(address erc20Address, address to) external onlyOwner {
        IERC20 erc20Token = IERC20(erc20Address);
        uint256 balance = erc20Token.balanceOf(address(this));
        erc20Token.safeTransfer(to, balance);
    }

    // recover
    function withdrawERC721(address nftAddress, uint256 tokenId, address to) external onlyOwner {
        IERC721 nft = IERC721(nftAddress);
        require(nft.ownerOf(tokenId) == address(this), "this contract is not the owner");
        nft.safeTransferFrom(address(this), to, tokenId);
    }

    function checkNFTOwner(address nftAddress, uint256 tokenId) public view returns (address) {
        IERC721 nft = IERC721(nftAddress);
        return nft.ownerOf(tokenId);
    }

    function checkNftAvailable(address nftAddress) public view returns (bool) {
        return _nftAvailable[nftAddress];
    }

    function checkERC20Support(address erc20Address) public view returns (bool) {
        return _erc20Available[erc20Address];
    }

    // function isTransactionIdExists(uint256 transactionId) public view returns (bool) {
    //     return _isTransactionIdExists[transactionId];
    // }

    function isOrderCanceledOrFinished(uint256 transactionId) public view returns (bool) {
        return _orderCanceledOrFinished[transactionId];
    }

    function tokenHighestBidValue(address nftAddress, uint256 tokenId) public view returns (uint256) {
        return _auctionStatus[nftAddress][tokenId].highestBid;
    }

    function tokenHighestBidAddress(address nftAddress, uint256 tokenId) public view returns (address) {
        return _auctionStatus[nftAddress][tokenId].highestBidder;
    }

    function isAuctionOpen(address nftAddress, uint256 tokenId) public view returns (bool) {
        return !_auctionStatus[nftAddress][tokenId].isMarketPaused;
    }

    function pauseAuction(address nftAddress, uint256 tokenId, bool pause) external onlyOwner {
        _auctionStatus[nftAddress][tokenId].isMarketPaused = pause;
    }

    // this function is to bid on auction. If doesn't win, money will be transferred back
    function bid(
        uint256 newBidPrice,
        TransactionInput memory input,
        bytes memory sellerSig,
        bytes memory validatorSig) public payable nonReentrant {
        // check whether current transaction satisfies requirements
        require(!_auctionStatus[input.nftAddress][input.tokenId].isMarketPaused, "market is paused now, try later");
        require(block.timestamp <= input.auctionEndTime, "Auction already ended.");
        if (input.erc20Address == BNB_ADDRESS) {   // BNB pay
            require(msg.value == newBidPrice, "newBidPrice should be == sent BNB");
        }
        require(newBidPrice >= _auctionStatus[input.nftAddress][input.tokenId].highestBid.mul(21).div(20), "New bid must be at least 5% larger than the current max bid");
        // require(!_isTransactionIdExists[input.transactionId], "Invalid: transactionId has already existed!");
        require(!_orderCanceledOrFinished[input.transactionId], "Invalid: transactionId has already canceled or finished!");
        require(_nftAvailable[input.nftAddress], "Invalid: this NFT address is not available");
        require(_erc20Available[input.erc20Address], "Invalid: this erc20 token is not available");

        IERC721 nft = IERC721(input.nftAddress);
        address currentOwner = nft.ownerOf(input.tokenId);
        require(_msgSender() != currentOwner , "owner can not be the buyer");

        // check validator signature
        bytes32 validatorHash = keccak256(abi.encodePacked(input.transactionId, input.seller, input.nftAddress, input.tokenId, input.erc20Address, input.price, input.auctionEndTime));
        require(isSignatureValid(validatorSig, validatorHash, _validator), "validator signature error");
        // check seller signature
        bytes32 sellerHash = keccak256(abi.encodePacked(input.seller, input.nftAddress, input.tokenId, input.erc20Address, input.price, input.kind, input.salt, input.auctionEndTime));
        require(isSignatureValid(sellerSig, ECDSA.toEthSignedMessageHash(sellerHash), currentOwner), "seller signature error");

        // if current bid is not the first bid
        address highestBidder = _auctionStatus[input.nftAddress][input.tokenId].highestBidder;
        uint256 highestBid = _auctionStatus[input.nftAddress][input.tokenId].highestBid;
        if (highestBid != 0) {
            // refund money to previous highest bidder
            refundBidPrice(
                input.nftAddress, 
                input.tokenId, 
                highestBidder, 
                highestBid);
        }

        // reserve current auction parameters into status
        _auctionStatus[input.nftAddress][input.tokenId].highestBidder = _msgSender();
        _auctionStatus[input.nftAddress][input.tokenId].highestBid = newBidPrice;
        _auctionStatus[input.nftAddress][input.tokenId].transactionId = input.transactionId;
        _auctionStatus[input.nftAddress][input.tokenId].ended = false;

        if (input.erc20Address != BNB_ADDRESS) {
            // transfer ERC20 from user to Auction contract
            IERC20 erc20Token = IERC20(input.erc20Address);
            require(erc20Token.balanceOf(_msgSender()) >= newBidPrice, "not enough ERC20 token balance to buy");
            erc20Token.safeTransferFrom(_msgSender(), address(this), newBidPrice);
        }

        emit HighestBidIncreased(input.transactionId, input.nftAddress, input.tokenId, newBidPrice);

        // current bid has been finished, log it into the mapping 
        // _isTransactionIdExists[input.transactionId] = true;
        // _orderCanceledOrFinished[input.transactionId] = true;
    }

    // this function is for nft owner to cancel the auction
    // owner can cancel the order ONLY when there is no bid.
    function cancelAuction(
        TransactionInput calldata input,
        bytes calldata sellerSig) public nonReentrant {
        // check whether the auction can be canceled
        require(!_auctionStatus[input.nftAddress][input.tokenId].isMarketPaused, "market is paused now, try later");
        require(_auctionStatus[input.nftAddress][input.tokenId].highestBid == 0, "can NOT cancel order with non-zero bid");
        require(!_orderCanceledOrFinished[input.transactionId], "Invalid: transactionId has already canceled or finished!");
        IERC721 nft = IERC721(input.nftAddress);
        require(_msgSender() == nft.ownerOf(input.tokenId) , "msg.sender must be the current owner");
        require(_msgSender() == input.seller , "msg.sender must be the seller");

        // check seller signature
        bytes32 sellerHash = keccak256(abi.encodePacked(input.seller, input.nftAddress, input.tokenId, input.erc20Address, input.price, input.kind, input.salt, input.auctionEndTime));
        require(isSignatureValid(sellerSig, ECDSA.toEthSignedMessageHash(sellerHash), input.seller), "seller signature error");

        // mark the current transaction as canceled
        _orderCanceledOrFinished[input.transactionId] = true;
        
        emit CancelOrder(input.transactionId, input.nftAddress, input.tokenId, input.seller, input.erc20Address, input.price, input.auctionEndTime);
    }

    // only seller or winner can trigger it, after the auction ends|在拍卖成功后取回
    function auctionEnd(TransactionInput calldata input) public payable nonReentrant {
        require(!_auctionStatus[input.nftAddress][input.tokenId].ended, "auctionEnd has already been called.");
        require((_msgSender() == input.seller) || (_msgSender() == _auctionStatus[input.nftAddress][input.tokenId].highestBidder), "only seller or highest bidder can trigger it");

        // if no one joins the auction, return NFT to seller
        if (_auctionStatus[input.nftAddress][input.tokenId].highestBid == 0) {
            return;
        }

        _transferToken(_auctionStatus[input.nftAddress][input.tokenId].highestBid, input.erc20Address, input.seller, _auctionStatus[input.nftAddress][input.tokenId].highestBidder);
        
        IERC721 nft = IERC721(input.nftAddress);
        nft.safeTransferFrom(input.seller, _auctionStatus[input.nftAddress][input.tokenId].highestBidder, input.tokenId);

        _auctionStatus[input.nftAddress][input.tokenId].ended = true;
        _orderCanceledOrFinished[_auctionStatus[input.nftAddress][input.tokenId].transactionId] = true;

        emit AuctionEnded(
            _auctionStatus[input.nftAddress][input.tokenId].transactionId, 
            input.nftAddress, 
            input.tokenId, 
            input.seller,
            _auctionStatus[input.nftAddress][input.tokenId].highestBidder,
            input.erc20Address,
            _auctionStatus[input.nftAddress][input.tokenId].highestBid);
    }

    function isSignatureValid(bytes memory signature, bytes32 hashCode, address signer) public pure returns (bool) {
        address recoveredSigner = ECDSA.recover(hashCode, signature);
        return signer == recoveredSigner;
    }

    function refundBidPrice(address nftAddress, uint256 tokenId, address bidder, uint256 amount) internal {
        if (nftAddress == BNB_ADDRESS) {
            payable(bidder).transfer(amount);
        } else {
            IERC20 erc20Token = IERC20(nftAddress);
            erc20Token.safeTransferFrom(address(this), bidder, amount);
        }
        _auctionStatus[nftAddress][tokenId].highestBid = 0;
    }

    function _transferToken(uint256 totalPayment, address erc20Address, address seller, address buyer) internal {
        uint256 totalFee = totalPayment.mul(fee).div(BASE);
        uint256 remaining = totalPayment.sub(totalFee);

        if (erc20Address == BNB_ADDRESS) {   // BNB payment
            payable(seller).transfer(remaining);
        } else {     // ERC20 token payment
            IERC20 erc20Token = IERC20(erc20Address);
            require(erc20Token.balanceOf(buyer) >= totalPayment, "not enough ERC20 token balance to buy");
            erc20Token.safeTransferFrom(buyer, seller, remaining);
            erc20Token.safeTransferFrom(buyer, address(this), totalFee);
        }
    }

    /**
     * @dev See {IERC721Receiver-onERC721Received}.
     *
     * Always returns `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(address, address, uint256, bytes memory) public override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}