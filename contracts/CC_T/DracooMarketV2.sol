// SPDX-License-Identifier: MIT
// pragma solidity ^0.6.0;
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


contract DracooMarket is Context, Ownable, IERC721Receiver, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct TransactionInput {
        uint256 transactionId;
        address seller;
        address nftAddress;
        uint256 tokenId;
        address erc20Address;
        uint256 price;
        uint256 kind;
        uint256 salt;
    }

    struct Detail {
        address seller;
        address buyer;
        address nftAddress;
        uint256 tokenId;
        address erc20Address;
        uint256 price;
        uint256 timeStamp;
        uint8 kind;
    }

    // BNB
    address private constant BNB_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    uint32 public constant BASE = 1e6;
    uint8 private constant KIND_BUY = 1;
    bool public isMarketPaused;
    uint32 public fee;
    // signer
    address private _validator;

    // nftAddress is added to the market or not
    mapping(address => bool) private _nftAvailable;
    // erc20Address is available or not
    mapping(address => bool) private _erc20Available;
    // transactionId => Detail
    mapping(uint256 => Detail) private _historyDetail;
    // transactionId => bool; exist or not
    mapping(uint256 => bool) private _isTransactionIdExists;
    // transactionId => bool; Order canceled or finished
    mapping(uint256 => bool) private _orderCanceledOrFinished;

    event BuyNFT(uint256 indexed transactionId, address indexed nftAddress, uint256 tokenId, address seller, address buyer, address erc20Address, uint256 salePrice);
    event CancelOrder(uint256 indexed transactionId, address indexed nftAddress, uint256 tokenId, address seller, address erc20Address, uint256 salePrice);

    constructor (address _newValidator) public {
        isMarketPaused = true;
        fee = 4 * 1e4;   // 4%, 40000/1000000 = 0.04
        _erc20Available[BNB_ADDRESS] = true;
        _validator = _newValidator;
    }

    modifier marketNotPaused() {
        require(!isMarketPaused, "market is paused now, try later");
        _;
    }

    function pauseMarket(bool pause) external onlyOwner {
        isMarketPaused = pause;
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

    function checkNftAvailable(address nftAddress) public view returns (bool) {
        return _nftAvailable[nftAddress];
    }

    function checkERC20Support(address erc20Address) public view returns (bool) {
        return _erc20Available[erc20Address];
    }

    function isTransactionIdExists(uint256 transactionId) public view returns (bool) {
        return _isTransactionIdExists[transactionId];
    }

    function checkHistoryDetail(uint256 transactionId) public view returns (Detail memory) {
        require(_isTransactionIdExists[transactionId], "transactionId does not exist");
        return _historyDetail[transactionId];
    }

    function isOrderCanceledOrFinished(uint256 transactionId) public view returns (bool) {
        return _orderCanceledOrFinished[transactionId];
    }

    // if this NFT traded by ERC20 token, buyer must be approve to this contract
    // Seller must "setApprovalForAll" this contract as the operator
    function buyNFT(TransactionInput calldata input,
                    bytes calldata sellerSig,
                    bytes calldata validatorSig) public payable nonReentrant marketNotPaused {
        
        require(!_isTransactionIdExists[input.transactionId], "Invalid: transactionId has already existed!");
        require(!_orderCanceledOrFinished[input.transactionId], "Invalid: transactionId has already canceled or finished!");
        require(_nftAvailable[input.nftAddress], "Invalid: this NFT address is not available");
        require(_erc20Available[input.erc20Address], "Invalid: this erc20 token is not available");
        IERC721 nft = IERC721(input.nftAddress);
        address currentOwner = nft.ownerOf(input.tokenId);
        require(_msgSender() != currentOwner , "owner can not be the buyer");

        // check validator signature
        bytes32 validatorHash = keccak256(abi.encodePacked(input.transactionId, input.seller, input.nftAddress, input.tokenId, input.erc20Address, input.price));
        require(isSignatureValid(validatorSig, validatorHash, _validator), "validator signature error");
        // check seller signature
        bytes32 sellerHash = keccak256(abi.encodePacked(input.seller, input.nftAddress, input.tokenId, input.erc20Address, input.price, input.kind, input.salt));
        require(isSignatureValid(sellerSig, ECDSA.toEthSignedMessageHash(sellerHash), currentOwner), "seller signature error");

        _transferToken(input.price, input.erc20Address, input.seller, _msgSender());
        nft.safeTransferFrom(input.seller, _msgSender(), input.tokenId);

        _historyDetail[input.transactionId] = Detail({
            seller: input.seller,
            buyer: _msgSender(),
            nftAddress: input.nftAddress,
            tokenId: input.tokenId,
            erc20Address: input.erc20Address, 
            price: input.price, 
            timeStamp: block.timestamp, 
            kind: KIND_BUY
        });
        _isTransactionIdExists[input.transactionId] = true;
        _orderCanceledOrFinished[input.transactionId] = true;

        emit BuyNFT(input.transactionId, input.nftAddress, input.tokenId, input.seller, _msgSender(), input.erc20Address, input.price);
    }
    //取消订单
    function cancelOrder(TransactionInput calldata input,
                         bytes calldata sellerSig) public nonReentrant marketNotPaused {

        require(!_orderCanceledOrFinished[input.transactionId], "Invalid: transactionId has already canceled or finished!");
        IERC721 nft = IERC721(input.nftAddress);
        address currentOwner = nft.ownerOf(input.tokenId);
        require(_msgSender() == currentOwner , "msg.sender must be the current owner");
        require(_msgSender() == input.seller , "msg.sender must be the seller");

        // check seller signature
        bytes32 sellerHash = keccak256(abi.encodePacked(input.seller, input.nftAddress, input.tokenId, input.erc20Address, input.price, input.kind, input.salt));
        require(isSignatureValid(sellerSig, ECDSA.toEthSignedMessageHash(sellerHash),  ), "seller signature error");

        _orderCanceledOrFinished[input.transactionId] = true;
        
        emit CancelOrder(input.transactionId, input.nftAddress, input.tokenId, input.seller, input.erc20Address, input.price);
    }

    function isSignatureValid(bytes memory signature, bytes32 hashCode, address signer) public pure returns (bool) {
        address recoveredSigner = ECDSA.recover(hashCode, signature);
        return signer == recoveredSigner;
    }

    function _transferToken(uint256 totalPayment, address erc20Address, address seller, address buyer) internal {
        uint256 totalFee = totalPayment.mul(fee).div(BASE);
        uint256 remaining = totalPayment.sub(totalFee);

        if (erc20Address == BNB_ADDRESS) {   // BNB payment
            require(msg.value >= totalPayment, "not enough BNB balance to buy");
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