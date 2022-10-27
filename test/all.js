/* eslint-disable no-unused-vars */
const { expect } = require("chai");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { ethers, upgrades } = require("hardhat");
const { time } = require("@openzeppelin/test-helpers");

const Utils = require("./utils");

// MIXED TESTS

describe("All - TEST", async () => {
  let token,
    Token,
    root,
    Root,
    heap,
    Heap,
    ovrLand,
    OVRLand,
    assets3D,
    Assets3D;

  beforeEach(async () => {
    Root = await ethers.getContractFactory("Root");
    Heap = await ethers.getContractFactory("Heap");
    Token = await ethers.getContractFactory("Token"); // ERC20
    OVRLand = await ethers.getContractFactory("OVRLand"); // ERC721
    Assets3D = await ethers.getContractFactory("Assets3D"); // ERC721

    Heap = await ethers.getContractFactory("Heap");

    [
      owner, // 50 ether
      addr1, // 0
      addr2, // 0
      addr3, // 0
      addr4, // 0
      addr5, // 0
      addr6, // 0
      addr7, // 0
      addr8, // 0
      addr9, // 0
      addr10, // 0
      addr11, // 0
      addr12, // 0
      addr13, // 0
      addr14, // 0
      addr15, // 0
      addr16, // 0
      addr17, // 0
      addr18, // 1000 ether
    ] = await ethers.getSigners();
  });

  describe("Deployments", () => {
    it("Should deploy Token", async () => {
      token = await Token.deploy();
      await token.deployed();
      console.debug("\t\t\tToken deployed to:", token.address);
    });
    it("Should deploy heap", async () => {
      heap = await Heap.deploy();
      await heap.deployed();
      console.debug("\t\t\tHeap deployed to:", heap.address);
    });
    it("Should deploy OVRLand", async () => {
      ovrLand = await OVRLand.deploy();
      await ovrLand.deployed();
      console.debug("\t\t\tOVRLand deployed to:", ovrLand.address);
    });
    it("Should deploy 3DAssets", async () => {
      assets3D = await Assets3D.deploy();
      await assets3D.deployed();
      console.debug("\t\t\tAssets3D deployed to:", assets3D.address);
    });
    it("Should depoy root", async () => {
      Root = await ethers.getContractFactory("Root");
      root = await upgrades.deployProxy(Root, [
        addr18.address, // FEE RECEIVER ADDRESS
        500, // FEE PERCENTAGE
        token.address,
        heap.address,
        1,
        1,
      ]);
      await root.deployed();
      console.log("\t\t\tRoot deployed to:", root.address);
      currentBlock = await time.latest();
      console.debug(
        "\t\t\t",
        Utils.displayTime(Number(currentBlock.toString()))
      );
    });
  });

  describe("Mint Tokens", () => {
    it("Mint OVRLands", async () => {
      await ovrLand
        .connect(owner)
        .batchMintLands(
          [
            addr1.address,
            addr1.address,
            addr2.address,
            addr2.address,
            addr3.address,
            addr3.address,
          ],
          [1, 2, 3, 4, 5, 6]
        );

      const balanceAddr1 = await ovrLand.balanceOf(addr1.address);
      expect(balanceAddr1.toString()).to.equal("2");
    });

    it("Mint 3DAssets", async () => {
      await assets3D
        .connect(owner)
        .mintBatch(addr1.address, [1, 2, 3], [5, 5, 5], "0x");
    });

    it("Mint OVR Tokens", async () => {
      await token.connect(owner).transfer(addr1.address, Utils.toWei("1000"));
      await token.connect(owner).transfer(addr2.address, Utils.toWei("1000"));
      await token.connect(owner).transfer(addr3.address, Utils.toWei("1000"));
      await token.connect(owner).transfer(addr4.address, Utils.toWei("1000"));
    });
  });

  describe("Approve Root", () => {
    it("Approve Tokens", async () => {
      await assets3D.connect(addr1).setApprovalForAll(root.address, true);
      await ovrLand.connect(addr1).setApprovalForAll(root.address, true);
      await ovrLand.connect(addr2).setApprovalForAll(root.address, true);
      await ovrLand.connect(addr3).setApprovalForAll(root.address, true);

      await token
        .connect(addr1)
        .approve(root.address, Utils.toWei("100000000000"));
      await token
        .connect(addr2)
        .approve(root.address, Utils.toWei("100000000000"));
      await token
        .connect(addr3)
        .approve(root.address, Utils.toWei("100000000000"));
    });
  });

  describe("Add Allowed Address", () => {
    it("List tokens on Marketplace", async () => {
      await root.addAllowedAddress(ovrLand.address, 0); // as ERC721
      await root.addAllowedAddress(assets3D.address, 1); // as ERC1155
    });
  });

  describe("Tests", () => {
    it("addr1 - Should PASS createSale()", async () => {
      await root
        .connect(addr1)
        .createSale(ovrLand.address, [1], Utils.toWei("1"), [3], 0);
    });
    it("addr1 - Should FAIL createAuction()", async () => {
      now = await time.latest();
      start = now.add(time.duration.hours(1));
      endTime = now.add(time.duration.days(10));
      console.debug(
        "\t\t\tCurrent Time",
        Utils.displayTime(Number(now.toString()))
      );
      console.log("\t\t\tAuction start time:", Utils.displayTime(start));
      console.log("\t\t\tAuction end time:", Utils.displayTime(endTime));
      await expect(
        root
          .connect(addr1)
          .createAuction(
            ovrLand.address,
            1,
            web3.utils.toWei("1"),
            Number(BigInt(start).toString()),
            Number(BigInt(endTime).toString())
          )
      ).to.be.revertedWith("A09");
    });
    it("addr2 - Should PASS createAuction()", async () => {
      now = await time.latest();
      start = now.add(time.duration.hours(1));
      endTime = now.add(time.duration.days(10));
      console.debug(
        "\t\t\tCurrent Time",
        Utils.displayTime(Number(now.toString()))
      );
      console.log("\t\t\tAuction start time:", Utils.displayTime(start));
      console.log("\t\t\tAuction end time:", Utils.displayTime(endTime));
      await root
        .connect(addr2)
        .createAuction(
          ovrLand.address,
          3,
          web3.utils.toWei("1"),
          Number(BigInt(start).toString()),
          Number(BigInt(endTime).toString())
        );
    });
    it("addr2 - Should FAIL bid()", async () => {
      await expect(
        root.connect(addr2).bid(ovrLand.address, 3, web3.utils.toWei("1"))
      ).to.be.revertedWith("A10");
    });
    it("addr2 - Should FAIL bid() because it doesn't exist", async () => {
      await expect(
        root.connect(addr2).bid(ovrLand.address, 4, web3.utils.toWei("1"))
      ).to.be.revertedWith("A01");
    });
    //move time forward 1 day
    it("Move time forward 1 day", async () => {
      await time.increase(time.duration.days(1));
      currentBlock = await time.latest();
      console.debug(
        "\t\t\t",
        Utils.displayTime(Number(currentBlock.toString()))
      );
    });
    it("addr3 - Should PASS bid()", async () => {
      await root.connect(addr3).bid(ovrLand.address, 3, web3.utils.toWei("2"));
    });
    it("addr3 - Should PASS createOffer()", async () => {
      await root
        .connect(addr3)
        .createOffer(ovrLand.address, 3, web3.utils.toWei("1"));
    });
    it("addr3 - Should FAIL completeAuction() before expiration", async () => {
      await expect(
        root.connect(addr3).completeAuction(ovrLand.address, 3)
      ).to.be.revertedWith("A15");
    });
  });
});
