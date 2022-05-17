// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract PrivateMarket is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    address private _owner;

    struct TokenData {
        uint256 price;
        string name;
        string image;
        uint256 tokenId;
    }

    struct Message {
        address sender;
        string message;
        uint date;
    }

    // An array to store the data of all the tokens for a quick listing of all NFTs
    TokenData[] public tokensData;

    // Mapping of owners to an array of all the tokens they own
    mapping(address => uint256[]) private ownerByTokenId;

    // Mapping of tokenIds to the owner of the token
    mapping(uint256 => address) private tokenIdByOwner;

    // Mapping of tokenIds to the data of the token
    mapping(uint256 => TokenData) private tokenIdByTokenData;

    // Mapping of tokenIds to the comments of the token
    mapping(uint256 => Message[]) private messages;

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
    ) public ownsToken returns (uint256) {

        // Increment to the new tokenId
        _tokenIds.increment();

        // Mint a new token
        uint256 currentId = _tokenIds.current();
        _mint(msg.sender, currentId);
        _setTokenURI(currentId, tokenURI);

        // Assign the token to the owner
        ownerByTokenId[msg.sender].push(currentId);

        // Store the data of the token
        TokenData memory tokenData = TokenData(
            price,
            name,
            tokenURI,
            currentId
        );
        tokenIdByTokenData[currentId] = tokenData;
        tokensData.push(tokenData);

        // Map the token to the owner
        tokenIdByOwner[currentId] = msg.sender;

        // Get token transfer approval
        _approve(msg.sender, currentId);

        return currentId;
    }

    function getTokenData(uint256 tokenId)
        public
        view
        returns (TokenData memory)
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

    function purchaseToken(uint256 tokenId) public payable returns (uint256) {
        // Get the token price
        TokenData memory tokenData = tokenIdByTokenData[tokenId];
        uint256 price = tokenData.price;

        require(msg.value == price, "You must pay the full price");

        // Get the token owner
        address owner = tokenIdByOwner[tokenId];

        require(owner != msg.sender, "You cannot buy your own token");

        // Transfer the token
        _transfer(owner, msg.sender, tokenId);
        tokenIdByOwner[tokenId] = msg.sender;
        delete ownerByTokenId[owner][tokenId];
        ownerByTokenId[msg.sender].push(tokenId);

        // Make a payment to the owner of the token
        (bool sent,) = payable(owner).call{value:msg.value}("");
        require(sent, "Payment failed");

        return tokenId;
    }

    function createMessage(
        uint256 tokenId,
        string memory message
    ) public ownsToken {
        Message memory messageData = Message(msg.sender, message, block.timestamp);
        messages[tokenId].push(messageData);
    }

    function getMessages(uint256 tokenId)
        public
        view
        returns (Message[] memory)
    {
        return messages[tokenId];
    }
}
