// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "./SafeMath.sol";
import "./Counters.sol";
import "./Context.sol";
import "./Ownable.sol";
import "./MinterRole.sol";
import "./Pausable.sol";
import "./ERC721.sol";


contract Tickets is Context, Ownable, Pausable, ERC721 {
    using SafeMath for uint256;
    using Counters for Counters.Counter;

    Counters.Counter private _currentId;

    constructor() ERC721("Binance Market Tickets", "Tickets") public {

    }

    function mint(address to, uint256 amounts) public {
        for(uint256 i = 0; i < amounts; ++i) {
            _currentId.increment();
            uint256 mintIndex = _currentId.current();

            _safeMint(to, mintIndex);
        }
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