// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Swords is ERC721, ERC721Burnable, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("Swords", "Swr") {}

    struct Sword {
        uint ID;
        uint8 power;
        uint8 plus;
    }

    

    mapping(uint => Sword) public idToSwords;

    function safeMint(address to) public onlyOwner {
        _tokenIdCounter.increment();
        uint256 tokenId = _tokenIdCounter.current();
        uint8 additionalPower = rand(30);
        Sword memory sword;
        sword.ID = tokenId;
        sword.power = additionalPower;
        idToSwords[tokenId] = sword;
        _safeMint(to, tokenId);
    }

    function setSwordMap(uint _id, uint8 _power, uint8 _plus) public {
        idToSwords[_id].power = _power;
        idToSwords[_id].plus = _plus;
    }

    function burn(uint256 tokenId) public override onlyOwner{
        //solhint-disable-next-line max-line-length
        _burn(tokenId);
    }

    function viewSword(uint _id) public view returns(Sword memory){
        return idToSwords[_id];
    }

    function rand(uint8 range) private view returns(uint8) {
        return uint8(uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender)))) % range ;
    }
}
