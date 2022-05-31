// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "./SafeMath.sol";
import "./Context.sol";
import "./Ownable.sol";
import "./IERC721Receiver.sol";
import "../library/ReentrancyGuard.sol";
import "../library/ECDSA.sol";


interface IBNFT_Tickets {
    
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    function ownerOf(uint256 tokenId) external view returns (address owner);

}

interface IDracooMaster {
    
    function safeMint(address to) external returns (uint256);

}

// must be assigned as a MinterRole of "DracooMaster" contract
contract OpenTicket is Context, IERC721Receiver, ReentrancyGuard, Ownable {
    using SafeMath for uint256;

    IDracooMaster public dracoo;

    // signer
    address private _validator;
    bool private _isAvailable;


    event OpenTicketForDracoo(address indexed owner, address indexed ticketAddress, uint256 indexed dracooTokenId, uint256 ticketTokenId, uint256 kind);

    constructor (address dracooAddress, address _newValidator) public {
        dracoo = IDracooMaster(dracooAddress);
        _validator = _newValidator;
        _isAvailable = false;
    }

    function setNewValidator(address newValidator) external onlyOwner {
        _validator = newValidator;
    }

    function setAvailable(bool newState) external onlyOwner {
        _isAvailable = newState;
    }

    function isAvailable() public view returns(bool) {
        return _isAvailable;
    }

    // must call ticket contract's "setApproveForAll" 
    function openTicketForDracoo(address ticketAddress, uint256 ticketTokenId, uint256 kind, bytes memory signature) public nonReentrant returns(uint256) {
        require(isAvailable(), "not available now");
        address ticketOwner = IBNFT_Tickets(ticketAddress).ownerOf(ticketTokenId);
        require(_msgSender() == ticketOwner, "only ticket owner can open it");
        require(kind > 0 && kind <=3, "kind must be in the range of 1-3");
        // check validator signature
        bytes32 validatorHash = keccak256(abi.encodePacked(ticketTokenId, kind));
        require(isSignatureValid(signature, validatorHash, _validator), "validator signature error");

        IBNFT_Tickets(ticketAddress).safeTransferFrom(_msgSender(), address(this), ticketTokenId);

        uint256 dracooTokenId = dracoo.safeMint(ticketOwner);

        emit OpenTicketForDracoo(ticketOwner, ticketAddress, dracooTokenId, ticketTokenId, kind);
        return dracooTokenId;
    }

    function isSignatureValid(bytes memory signature, bytes32 hashCode, address signer) public pure returns (bool) {
        address recoveredSigner = ECDSA.recover(hashCode, signature);
        return signer == recoveredSigner;
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