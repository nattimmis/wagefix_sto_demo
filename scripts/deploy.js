const hre = require("hardhat");

async function main() {
  const WageFixSTO = await hre.ethers.getContractFactory("WageFixSTO");
  const sto = await WageFixSTO.deploy();
  await sto.deployed();
  console.log("✅ Contract deployed to:", sto.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
