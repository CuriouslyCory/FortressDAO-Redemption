const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Redemption contract", function () {
  it("Test Redemption Transaction", async function () {
    const [owner] = await ethers.getSigners();

    // deploy mock mim
    const MIMFactory = await ethers.getContractFactory("MagicInternetMoney");
    const mim = await MIMFactory.deploy("Magic Internet Money", "MIM");

    // deploy actual fort contract
    const FortFactory = await ethers.getContractFactory("FortERC20Token");
    const fort = await FortFactory.deploy();
    // set the owner address as vault for simplicity
    await fort.setVault(owner.address);
    // mint current supply
    await fort.mint(owner.address, 1825865 * Math.pow(10, 9));

    // validate fort exists and is of correct amounts 
    expect(await fort.balanceOf(owner.address)).to.equal(1825865 * Math.pow(10, 9));
    expect(await fort.totalSupply()).to.equal(1825865 * Math.pow(10, 9));

    // validate mim balance of owner
    const ownerBalance = await mim.balanceOf(owner.address);
    expect(await mim.totalSupply()).to.equal(ownerBalance);

    // deploy redemption contract
    const FortRedemptionFactory = await ethers.getContractFactory("FortRedemption");
    const fortRedemption = await FortRedemptionFactory.deploy(fort.address, mim.address);

    //transfer mim into contract as reserve supply
    await fort.increaseAllowance(fortRedemption.address, await fort.balanceOf(owner.address));
    await mim.increaseAllowance(fortRedemption.address, await mim.totalSupply());
    //await mim.transferFrom(owner.address, fortRedemption.address, await mim.totalSupply());
    await fortRedemption.makeRedeemable(await mim.totalSupply());

    // validate fort redemption has mim and original wallet is empty
    expect(await mim.balanceOf(fortRedemption.address)).to.equal(await mim.totalSupply());
    expect(await mim.balanceOf(owner.address)).to.equal(0);
    
    // attempt to redeem 100 tokens
    await fortRedemption.redeemTokens(owner.address, 100 * Math.pow(10, 9));

    expect(await mim.balanceOf(owner.address)).to.equal(766759864502);

  });
});