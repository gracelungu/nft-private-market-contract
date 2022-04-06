// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract PrivateMarket is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    address _owner;

    struct TokenData {
        uint256 price;
        string name;
        string image;
    }

    TokenData[] tokensData;
    mapping(address => uint256[]) private ownerByTokenId;
    mapping(uint256 => TokenData[]) private tokenIdByTokenData;

    constructor() ERC721("NFTPrivateMarket", "NFTPM") {
        _owner = msg.sender;
    }

    modifier ownsToken() {
        require(
            ownerByTokenId[msg.sender].length > 0 || msg.sender == _owner,
            "You must own a token"
        );
        _;
    }

    function createToken(
        string memory tokenURI,
        uint256 price,
        string memory name
    ) public payable ownsToken returns (uint256) {
        _tokenIds.increment();

        uint256 currentId = _tokenIds.current();
        _mint(msg.sender, currentId);
        _setTokenURI(currentId, tokenURI);

        ownerByTokenId[msg.sender].push(currentId);

        TokenData memory tokenData = TokenData(price, name, tokenURI);
        tokenIdByTokenData[currentId].push(tokenData);

        tokensData.push(tokenData);

        return currentId;
    }

    function getTokenData(uint256 tokenId)
        public
        view
        returns (TokenData[] memory)
    {
        return tokenIdByTokenData[tokenId];
    }

    function getOwnerTokens() public view returns (uint256[] memory) {
        return ownerByTokenId[msg.sender];
    }

    function getAddressTokens(address owner)
        public
        view
        returns (uint256[] memory)
    {
        return ownerByTokenId[owner];
    }

    function getAllTokenData() public view returns (TokenData[] memory) {
        return tokensData;
    }

    function purchaseToken(address buyer, uint256 tokenId) public payable {
        transferFrom(buyer, msg.sender, tokenId);
        uint256 tempId = ownerByTokenId[buyer][tokenId];

        delete ownerByTokenId[buyer][tokenId];
        ownerByTokenId[msg.sender].push(tempId);
    }
}
