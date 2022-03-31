import { expect } from "chai";
import { ethers } from "hardhat";

describe("PrivateMarket", function () {
  it("Should return the new greeting once it's changed", async function () {
    const PrivateMarket = await ethers.getContractFactory("PrivateMarket");
    const privateMarket = await PrivateMarket.deploy();
    await privateMarket.deployed();

    const tokenURI = "http://tokenURI";

    await privateMarket.createToken(tokenURI);

    const tokenIds = await privateMarket.getOwnerTokens();
    const tokenId = tokenIds.values().next().value.toString();

    const getTokenURI = await privateMarket.tokenURI(tokenId);

    expect(getTokenURI).to.equal(tokenURI);
  });
});
