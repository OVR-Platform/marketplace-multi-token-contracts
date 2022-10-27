/* eslint-disable no-unused-vars */
/* eslint-disable no-undef */
const { expect } = require("chai");
const { ethers, upgrades } = require("hardhat");
const { time } = require("@openzeppelin/test-helpers");

const Utils = require("./utils");

// ONLY OFFERS TESTS

describe("Offers - TEST", async () => {
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
    it("Should depoy root + heap.addAdminRole", async () => {
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

      // Add Heap Admin Role to Root
      await heap.addAdminRole(root.address);
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
          [addr1.address, addr1.address, addr2.address, addr2.address],
          [1, 2, 3, 4]
        );

      const balanceAddr1 = await ovrLand.balanceOf(addr1.address);
      expect(balanceAddr1.toString()).to.equal("2");
    });

    it("Mint 3DAssets", async () => {
      await assets3D
        .connect(owner)
        .mintBatch(addr1.address, [1, 2, 3], [5, 5, 5], "0x");

      await assets3D
        .connect(owner)
        .mintBatch(addr2.address, [4, 5, 6], [9, 9, 9], "0x");
    });

    it("Mint OVR Tokens", async () => {
      await token.connect(owner).transfer(addr1.address, Utils.toWei("1000"));
      await token.connect(owner).transfer(addr2.address, Utils.toWei("1000"));

      await token.connect(owner).transfer(addr10.address, Utils.toWei("1000"));
      await token.connect(owner).transfer(addr11.address, Utils.toWei("1000"));
    });
  });

  describe("Approve Root", () => {
    it("Approve Tokens", async () => {
      await assets3D.connect(addr1).setApprovalForAll(root.address, true);
      await assets3D.connect(addr5).setApprovalForAll(root.address, true);

      await assets3D.connect(addr14).setApprovalForAll(root.address, true);
      await assets3D.connect(addr15).setApprovalForAll(root.address, true);
      await assets3D.connect(addr16).setApprovalForAll(root.address, true);

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
        .connect(addr9)
        .approve(root.address, Utils.toWei("100000000000"));

      await token
        .connect(addr10)
        .approve(root.address, Utils.toWei("100000000000"));
      await token
        .connect(addr11)
        .approve(root.address, Utils.toWei("100000000000"));

      await token
        .connect(addr12)
        .approve(root.address, Utils.toWei("100000000000"));
    });
  });

  describe("Add Allowed Address", () => {
    it("List tokens on Marketplace", async () => {
      await root.addAllowedAddress(ovrLand.address, 0); // as ERC721
      await root.addAllowedAddress(assets3D.address, 1); // as ERC1155
    });
  });

  describe("ERC1155 - Tests", () => {
    it("PASS - Addr10 place Offer for tokenId 1, price 60 OVR", async () => {
      const offeredPrice = "60";

      const addr10BalanceBefore = await token.balanceOf(addr10.address);
      const rootBalanceBefore = await token.balanceOf(root.address);

      await root
        .connect(addr10)
        .createOffer(assets3D.address, 1, Utils.toWei(offeredPrice));

      const offerNumber = await root.offersCount.call();
      const offerIndexNext = Number(offerNumber.toString());
      console.debug("OfferIndexNext", offerIndexNext);

      // Get Offer using index
      const offer = await root.offers(Number(offerIndexNext) - 1);
      Utils.offerLogger(offer);

      const addr10BalanceAfter = await token.balanceOf(addr10.address);
      const rootBalanceAfter = await token.balanceOf(root.address);

      expect(Number(Utils.fromWei(addr10BalanceAfter))).to.be.equal(
        Number(Utils.fromWei(addr10BalanceBefore)) - Number(offeredPrice)
      );

      expect(Number(Utils.fromWei(rootBalanceAfter))).to.be.equal(
        Number(Utils.fromWei(rootBalanceBefore)) + Number(offeredPrice)
      );
    });

    it("PASS - Addr1 accept offer", async () => {
      const addr1BalanceBefore = await token.balanceOf(addr1.address);
      const feeReceiverBalanceBefore = await token.balanceOf(addr18.address);

      const offerNumber = await root.offersCount.call();
      const offerIndexNext = Number(offerNumber.toString());
      const offer = await root.offers(Number(offerIndexNext) - 1);

      await root.connect(addr1).fulfillOffer(1);

      const feeReceiverBalanceAfter = await token.balanceOf(addr18.address);
      const rootBalanceAfter = await token.balanceOf(root.address);
      const addr1BalanceAfter = await token.balanceOf(addr1.address);

      // Check contract balance
      expect(Utils.fromWei(rootBalanceAfter)).to.be.equal("0.0");

      // Check fee receiver balance
      expect(Number(Utils.fromWei(feeReceiverBalanceAfter))).to.be.equal(
        Number(Utils.fromWei(feeReceiverBalanceBefore)) +
          Number(Utils.fromWei(offer.price)) * 0.05
      );

      // Check addr1 balance
      expect(Number(Utils.fromWei(addr1BalanceAfter))).to.be.equal(
        Number(Utils.fromWei(addr1BalanceBefore)) +
          Number(Utils.fromWei(offer.price)) * 0.95
      );
    });

    it("FAIL - Provo a fare 2 offerte sullo stesso assetId", async () => {
      await root
        .connect(addr10)
        .createOffer(assets3D.address, 1, Utils.toWei("60"));

      await expect(
        root.connect(addr10).createOffer(assets3D.address, 1, Utils.toWei("60"))
      ).to.be.revertedWith("O07");
    });
    it("FAIL - Provo a chiamare Fullfill senza possedere asset", async () => {
      await expect(root.connect(addr2).fulfillOffer(1)).to.be.revertedWith(
        "ERC1155: caller is not token owner nor approved"
      );
    });
    it("FAIL - Test cancellazione offerta non creata da me", async () => {
      await expect(root.connect(addr1).deleteOffer(1)).to.be.revertedWith(
        "O08"
      );
    });

    // Il tutto si potrebbe considerare valido anche per ERC721
  });
});
