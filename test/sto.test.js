const { expect } = require("chai");

describe("WageFixSTO", function () {
  it("Should issue tokens only to whitelisted users", async function () {
    const [owner, user1] = await ethers.getSigners();
    const STO = await ethers.getContractFactory("WageFixSTO");
    const sto = await STO.deploy();
    await sto.whitelistInvestor(user1.address);
    await sto.issueTokens(user1.address, 1000);
    expect(await sto.balanceOf(user1.address)).to.equal(1000);
  });
});
