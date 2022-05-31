// SPDX-License-Identifier: MIT

// pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "./ERC721/SafeMath.sol";
import "./ERC721/Context.sol";
import "./ERC721/Ownable.sol";
import "./ERC721/MinterRole.sol";
import "./ERC721/Pausable.sol";
import "./ERC721/ERC721.sol";

//类|用于定义nft-tokenID
library Counters {
    using SafeMath for uint256;

    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }
    //返回数字
    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }
    //+1
    function increment(Counter storage counter) internal {
        // The {SafeMath} overflow check can be skipped here, see the comment at the top
        counter._value += 1;
    }
    // -1
    function decrement(Counter storage counter) internal {
        counter._value = counter._value.sub(1);
    }
}
//头像nft
contract ProfileNFT is Context, Ownable, MinterRole, Pausable, ERC721 {
    using SafeMath for uint256;
    using Counters for Counters.Counter;

    Counters.Counter private _currentId;

    // mapping tokenId => profile class
    mapping(uint256 => uint256) private _classOf;

    event ProfileMinted(address indexed owner, uint256 indexed tokenId, uint256 indexed classId);

    constructor() ERC721("Dracoo Profile", "DracooP") public {

    }

    // start from tokenId = 1
    //空投nft
    function safeMint(address to, uint256 classId) public virtual onlyMinter returns(uint256) {
        require(classId > 0, "input class must > 0");

        _currentId.increment();
        uint256 tokenId = _currentId.current();
        _classOf[tokenId] = classId;
        _safeMint(to, tokenId);

        emit ProfileMinted(to, tokenId, classId);

        return tokenId;
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

    function classOf(uint256 tokenId) public view returns(uint256) {
        require(_exists(tokenId), "ProfileNFT: query for nonexistance tokenId");
        return _classOf[tokenId];
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