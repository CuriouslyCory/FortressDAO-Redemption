const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Redemption contract", function () {
  it("Test Redemption Transaction", async function () {
    const [owner] = await ethers.getSigners();
    const redeemableQuantityPure = 1859610;
    const redeemableQuantity = redeemableQuantityPure * Math.pow(10, 9);

    // deploy mock fusd
    const FUSDFactory = await ethers.getContractFactory("FUSDMock");
    const fusd = await FUSDFactory.deploy("FortUSD", "FUSD");

    // deploy mock sFORT contract
    const sFortFactory = await ethers.getContractFactory("sFORT");
    const sfort = await sFortFactory.deploy("Staked Fortress", "sFORT", redeemableQuantityPure);

    // deploy actual wsFORT contract
    const wsFortFactory = await ethers.getContractFactory("wsFORT");
    const wsfort = await wsFortFactory.deploy(sfort.address);

    // wrap the redeemable supply
    await sfort.increaseAllowance(wsfort.address, await sfort.balanceOf(owner.address));
    await wsfort.wrap(redeemableQuantity);

    // validate wsFORT exists in wallet and is of correct amounts 
    const wrappedBalanceExpected = BigInt(redeemableQuantity / await sfort.index() * Math.pow(10, 9));
    expect(BigInt(await wsfort.balanceOf(owner.address))).to.equal(wrappedBalanceExpected);
    expect(await wsfort.totalSupply()).to.equal(wrappedBalanceExpected);

    // validate mim balance of owner
    const ownerBalance = await fusd.balanceOf(owner.address);
    expect(await fusd.totalSupply()).to.equal(ownerBalance);

    // deploy redemption contract
    const FortRedemptionFactory = await ethers.getContractFactory("wsFortRedemption");
    
    const fortRedemption = await FortRedemptionFactory.deploy(wsfort.address, fusd.address, redeemableQuantity);

    //transfer mim into contract as reserve supply
    await wsfort.increaseAllowance(fortRedemption.address, await wsfort.balanceOf(owner.address));
    await fusd.increaseAllowance(fortRedemption.address, await fusd.totalSupply());
    //await mim.transferFrom(owner.address, fortRedemption.address, await mim.totalSupply());
    await fortRedemption.makeRedeemable(await fusd.totalSupply());

    // validate fort redemption has mim and original wallet is empty
    expect(await fusd.balanceOf(fortRedemption.address)).to.equal(await fusd.totalSupply());
    expect(await fusd.balanceOf(owner.address)).to.equal(0);
    
    // attempt to redeem 100 tokens
    await fortRedemption.redeemTokens(owner.address, 100 * Math.pow(10, 9));

    expect(await mim.balanceOf(owner.address)).to.equal(766759864502);

  });
});