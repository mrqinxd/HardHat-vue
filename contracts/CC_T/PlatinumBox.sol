// SPDX-License-Identifier: MIT

// pragma solidity ^0.6.0;
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
//铂金盲盒
contract PlatinumBox is Context, Ownable, MinterRole, Pausable, ERC721 {
    using SafeMath for uint256;
    using Counters for Counters.Counter;

    uint256 public constant CAP = 1200;
    uint256 public constant ROUND1_CAP = 360;
    uint256 public constant ROUND2_CAP = 480;
    uint256 public constant ROUND1_PRICE = 90 * 1e16;  // 0.90 BNB
    uint256 public constant ROUND2_PRICE = 95 * 1e16;  // 0.95 BNB
    uint256 public maxPerTime = 6;

    bool public saleIsActive;
    uint256 public currentRound;
    Counters.Counter private _currentId;
    uint256 private _totalSold = 0;
    mapping(uint256 => uint256) private _roundToPrice;
    mapping(uint256 => uint256) private _roundToCap;

    event BuyPlatinumBox(address indexed to, uint256 indexed mintIndex, uint256 indexed roundNum);


    constructor() ERC721("Dracoo Platinum Box", "DracooPBox") public {
        saleIsActive = false;
        currentRound = 1;
        _roundToPrice[1] = ROUND1_PRICE;
        _roundToPrice[2] = ROUND2_PRICE;
        _roundToCap[1] = ROUND1_CAP;
        _roundToCap[2] = ROUND1_CAP.add(ROUND2_CAP);
        _roundToCap[3] = CAP;
    }

    function setMaxPerTime(uint256 newMax) public onlyOwner {
        maxPerTime = newMax;
    }

    // Set round first, then active sale
    function setCurrentRound(uint256 roundNum) public onlyOwner {
        require(roundNum == 1 || roundNum == 2 || roundNum == 3, "roundNum must be 1 or 2 or 3");
        currentRound = roundNum;
    }

    function setSaleIsActive(bool newState) public onlyOwner {
        saleIsActive = newState;
    }

    function checkCurrentRoundRemaining() public view returns (uint256) {
        require(saleIsActive, "this round sale does not start yet");
        return _roundToCap[currentRound].sub(_totalSold);
    }

    //限制地址条件mint盲盒
    function mintbyMinter(address to, uint256 amounts) public onlyMinter {
        require(_totalSold.add(amounts) <= CAP, "can only mint 1200 platinum boxes!");
        require(currentRound == 3, "must be in the 3rd round");
        
        _totalSold = _totalSold.add(amounts);
        for(uint256 i = 0; i < amounts; ++i) {
            _currentId.increment();
            uint256 mintIndex = _currentId.current();
                
            _safeMint(to, mintIndex);

            emit BuyPlatinumBox(to, mintIndex, currentRound);
        }
    }

    // start from tokenId = 1
    //公开mint盲盒
    function buyPlatinumBox(uint256 amounts) public payable {
        require(_msgSender() == tx.origin, "contract can not buy");
        require(saleIsActive, "sale does not start yet");
        require(currentRound == 1 || currentRound == 2, "currentRound must be in Round #1 or #2");
        require(amounts <= maxPerTime, "can not excced maxPerTime limit");
        require(_totalSold.add(amounts) <= _roundToCap[currentRound], "can not exceed max cap in this round");
        require(amounts.mul(_roundToPrice[currentRound]) <= msg.value, "BNB value sent is not enough");

        _totalSold = _totalSold.add(amounts);
        for(uint256 i = 0; i < amounts; ++i) {
            _currentId.increment();
            uint256 mintIndex = _currentId.current();

            _safeMint(_msgSender(), mintIndex);

            emit BuyPlatinumBox(_msgSender(), mintIndex, currentRound);
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

    function withdrawBNB(address payable to) public onlyOwner {
        uint256 balance = address(this).balance;
        to.transfer(balance);
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