// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract PrivateMarket is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    mapping(address => uint256[]) private tokenIdsByOwner;

    constructor() ERC721("NFTPrivateMarket", "NFTPM") {}

    function createToken(string memory tokenURI) public returns (uint256) {
        _tokenIds.increment();

        uint256 currentId = _tokenIds.current();
        _mint(msg.sender, currentId);
        _setTokenURI(currentId, tokenURI);

        tokenIdsByOwner[msg.sender].push(currentId);

        return currentId;
    }

    function getOwnerTokens() public view returns (uint256[] memory) {
        return tokenIdsByOwner[msg.sender];
    }
}
