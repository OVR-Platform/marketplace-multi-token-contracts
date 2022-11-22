const { ethers, upgrades } = require("hardhat");

async function main() {
  const ProxyAddress = "0x911EF6e7de0101325827D93ab1f9859286ca24F8";
  const heapOffer = "0xeb1ddcc9f38e25bdafb1ed99859f626d8373cda8";
  const heapSale = "0xaab3aba2a97232792e2fbb3e4c4c7c6de1cd0266";
  const _feeReceiver = "0x00000000000B186EbeF1AC9a27C7eB16687ac2A9";
  const _feePercentage = "500"; // 5%
  const _ovrTokenAddress = "0xC9A4fAafA5Ec137C97947dF0335E8784440F90B5";
  const Root = await ethers.getContractFactory("Root");

  const upgraded = await upgrades.upgradeProxy(
    ProxyAddress,
    Root,
    [
      _feeReceiver,
      _feePercentage,
      _ovrTokenAddress,
      heapSale,
      heapOffer,
      14,
      14,
    ],
    {
      initializer: "initialize",
      kind: "uups",
    }
  );

  console.log("Proxy Upgraded: ", upgraded.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
