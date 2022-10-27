const { ethers, upgrades } = require("hardhat");

async function main() {
  console.log("Deploying...");

  const Heap = await ethers.getContractFactory("Heap");
  const heap = await Heap.deploy();
  await heap.deployed();
  console.log("Heap deployed to:", heap.address);

  const Assets3D = await ethers.getContractFactory("Assets3D");
  const assets3D = await Assets3D.deploy();
  await assets3D.deployed();
  console.log("Assets3D deployed to:", assets3D.address);

  const _ovrTokenAddress = "0xC9A4fAafA5Ec137C97947dF0335E8784440F90B5";

  const _feeReceiver = "0x00000000000B186EbeF1AC9a27C7eB16687ac2A9";
  const _feePercentage = "500"; // 5%

  const Root = await ethers.getContractFactory("Root");

  const market = await upgrades.deployProxy(
    Root,
    [_feeReceiver, _feePercentage, _ovrTokenAddress, heap.address, 1, 1],
    {
      initializer: "initialize",
      kind: "uups",
    }
  );
  await market.deployed();
  console.log("Proxy deployed to: ", market.address);

  //add allowed address
  const tx = await market.addAllowedAddress(assets3D.address, 1);
  await tx.wait(1);
  console.log("Added assets3D as allowed...", tx.txHash);

  //Done!
  console.log("Done!");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
