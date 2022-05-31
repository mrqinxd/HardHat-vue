// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "./ERC721/SafeMath.sol";
import "./ERC721/Context.sol";
import "./ERC721/Ownable.sol";
import "./ERC721/MinterRole.sol";
import "./ERC721/Pausable.sol";
import "./ERC721/ERC721.sol";

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

//DRA-NFT主合约
contract DracooMaster is Context, Ownable, MinterRole, Pausable, ERC721 {
    using SafeMath for uint256;
    using Counters for Counters.Counter;

    uint256 private _maxBreedTimes = 5;
    Counters.Counter private _currentId;

    mapping(uint256 => uint256[2]) private _parents;
    mapping(uint256 => uint256) private _breedTimes;

    constructor() ERC721("Dracoo Master", "Dracoo") public {

    }

    // start from tokenId = 1; all minted tokens(include airdrops)' parents are uint256(0)
    function safeMint(address to) public virtual onlyMinter returns(uint256) {
        _currentId.increment();
        uint256 tokenId = _currentId.current();
        _setParents(tokenId, [uint256(0), uint256(0)]);
        _safeMint(to, tokenId);

        return tokenId;
    }
    //不同类型的购买
    function breedMint(address to, uint256[2] memory parentsId) public virtual onlyMinter returns(uint256) {
        require((_breedTimes[parentsId[0]] < _maxBreedTimes) && (_breedTimes[parentsId[1]] < _maxBreedTimes), "DracooMaster: breed times exceed!");
        _currentId.increment();
        uint256 tokenId = _currentId.current();
        _setParents(tokenId, parentsId);
        for (uint256 i = 0; i < parentsId.length; i++) {
            _breedTimes[parentsId[i]] = _breedTimes[parentsId[i]].add(1);
        }

        _safeMint(to, tokenId);

        return tokenId;
    }

    function burn(uint256 tokenId) public virtual {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721Burnable: caller is not owner nor approved");
        _burn(tokenId);
    } 

    function checkParents(uint256 tokenId) public view returns(uint256[2] memory) {
        require(_exists(tokenId), "DracooMaster: query for nonexistance tokenId");
        return _parents[tokenId];
    }

    function checkBreedTimes(uint256 tokenId) public view returns(uint256) {
        return _breedTimes[tokenId];
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

    function setMaxBreedTimes(uint256 newTimes) public onlyOwner {
        _maxBreedTimes = newTimes;
    }

    function _setParents(uint256 childId, uint256[2] memory parentsId) internal {
        require(!_exists(childId), "childId exists");

        _parents[childId] = parentsId;
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