/* eslint-disable no-unused-vars */
const { expect } = require("chai");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { ethers, upgrades } = require("hardhat");
const { time } = require("@openzeppelin/test-helpers");

const Utils = require("./utils");

// ONLY SALES TESTS

describe("Sales - TEST", async () => {
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
      //add store to heap
      await heap.addStore(root.address);
      console.log("\t\t\tRoot added to Heap");
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

      await assets3D
        .connect(owner)
        .mintBatch(addr5.address, [4, 5, 6, 20], [9, 9, 9, 1], "0x");

      await assets3D
        .connect(owner)
        .mintBatch(addr14.address, [11, 12], [1000, 1000], "0x");

      await assets3D
        .connect(owner)
        .mintBatch(addr15.address, [11, 12], [1000, 1000], "0x");

      await assets3D
        .connect(owner)
        .mintBatch(addr16.address, [11, 12], [1000, 1000], "0x");

      await assets3D.connect(owner).mintBatch(addr9.address, [20], [5], "0x");
    });

    it("Mint OVR Tokens", async () => {
      await token.connect(owner).transfer(addr1.address, Utils.toWei("1000"));
      await token.connect(owner).transfer(addr2.address, Utils.toWei("1000"));
      await token.connect(owner).transfer(addr3.address, Utils.toWei("1000"));
      await token.connect(owner).transfer(addr4.address, Utils.toWei("1000"));

      await token.connect(owner).transfer(addr8.address, Utils.toWei("10000"));
    });
  });

  describe("Approve Root", () => {
    it("Approve Tokens", async () => {
      await assets3D.connect(addr1).setApprovalForAll(root.address, true);
      await assets3D.connect(addr5).setApprovalForAll(root.address, true);
      await assets3D.connect(addr9).setApprovalForAll(root.address, true);

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
        .connect(addr3)
        .approve(root.address, Utils.toWei("100000000000"));
      await token
        .connect(addr4)
        .approve(root.address, Utils.toWei("100000000000"));
      await token
        .connect(addr5)
        .approve(root.address, Utils.toWei("100000000000"));

      await token
        .connect(addr8)
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
    it("Should FAIL createSale() if assets not owned", async () => {
      await expect(
        root
          .connect(addr4)
          .createSale(assets3D.address, [1], Utils.toWei("100"), [2], 0)
      ).to.be.revertedWith("S12");
    });
    it("Should FAIL createSale() if owned assets amount is lower than declared", async () => {
      await expect(
        root
          .connect(addr1)
          .createSale(assets3D.address, [1], Utils.toWei("100"), [6], 0)
      ).to.be.revertedWith("S12");
    });
    it("Should FAIL cancelSale() of never created sale", async () => {
      await expect(root.connect(addr1).cancelSale(1)).to.be.revertedWith("S15");
    });
    it("Should FAIL buy() of invalid sale", async () => {
      await expect(root.connect(addr1).buy(1, "2")).to.be.revertedWith("O03");
    });
    it("Should FAIL createSale() ADVANCED Order if missing Role", async () => {
      await expect(
        root
          .connect(addr1)
          .createSale(assets3D.address, [1], Utils.toWei("100"), [2], 1)
      ).to.be.revertedWith("S18");
    });
    it("Should PASS createSale() BASIC Order", async () => {
      await root
        .connect(addr1)
        .createSale(assets3D.address, [1], Utils.toWei("100"), [2], 0);
    });
    it("Should PASS cancelSale()", async () => {
      const sales = await root.viewSalesByAsset(assets3D.address, 1, 1);
      const indexOrder = sales[0]["indexOrder"];
      await root.connect(addr1).cancelSale(indexOrder.toString());
    });
    it("Should PASS createSale() BASIC Order", async () => {
      await root
        .connect(addr1)
        .createSale(assets3D.address, [1], Utils.toWei("200"), [2], 0);
    });
    it("Shold FAIL buy() if ovr token balance lower than price", async () => {
      const sales = await root.viewSalesByAsset(assets3D.address, 1, 1);
      const indexOrder = sales[0]["indexOrder"];

      await expect(root.connect(addr5).buy(indexOrder, 2)).to.be.revertedWith(
        "ERC20: transfer amount exceeds balance"
      );
    });
    it("Should FAIL buy() if amount over than placed on sale", async () => {
      const sales = await root.viewSalesByAsset(assets3D.address, 1, 1);
      const indexOrder = sales[0]["indexOrder"];

      await expect(root.connect(addr3).buy(indexOrder, 5)).to.be.revertedWith(
        "O04"
      );
    });

    it("Should PASS createSale() BASIC Order - Addr5 has ids[5,6,7] amounts[9,9,9], create sale for 8 items", async () => {
      await root
        .connect(addr5)
        .createSale(assets3D.address, [4], Utils.toWei("50"), [8], 0);

      const sales = await root.viewSalesByAsset(assets3D.address, 4, 10);
      console.log("IlTESTT", sales);
    });

    it("Should PASS buy() (3/8 assets), remaining 5", async () => {
      const sales = await root.viewSalesByAsset(assets3D.address, 4, 5);
      const indexOrder = sales[0]["indexOrder"];
      await root.connect(addr1).buy(indexOrder, 3);
    });
    it("Should PASS buy() (2/5 assets), remaining 3", async () => {
      const sales = await root.viewSalesByAsset(assets3D.address, 4, 5);
      const indexOrder = sales[0]["indexOrder"];
      await root.connect(addr8).buy(indexOrder, 2);
    });
    it("Should FAIL buy() (5/3 assets) - amount over sale!", async () => {
      const sales = await root.viewSalesByAsset(assets3D.address, 4, 5);
      const indexOrder = sales[0]["indexOrder"];
      await expect(root.connect(addr8).buy(indexOrder, 5)).to.be.revertedWith(
        "O04"
      );
    });

    it("Should PASS buy() (3/3 assets) - amount over sale!", async () => {
      const sales = await root.viewSalesByAsset(assets3D.address, 4, 5);
      const indexOrder = sales[0]["indexOrder"];
      await root.connect(addr8).buy(indexOrder, 3);

      const sales2 = await root.viewSalesByAsset(assets3D.address, 4, 5);
    });

    it("Stress Test", async () => {
      const multipleCreateSale = async (
        tokenAddress,
        tokenIds,
        price,
        amount,
        orderType,
        repeat,
        loggedUser
      ) => {
        for (let i = 0; i < repeat; i++) {
          await root
            .connect(loggedUser)
            .createSale(tokenAddress, tokenIds, price, amount, orderType);
        }
      };

      await multipleCreateSale(
        assets3D.address,
        [12],
        Utils.toWei("1234"),
        [2],
        0,
        1,
        addr14
      );

      await multipleCreateSale(
        assets3D.address,
        [12],
        Utils.toWei("123"),
        [2],
        0,
        1,
        addr14
      );

      await multipleCreateSale(
        assets3D.address,
        [11],
        Utils.toWei("123"),
        [2],
        0,
        50,
        addr14
      );

      await multipleCreateSale(
        assets3D.address,
        [11],
        Utils.toWei("2"),
        [1],
        0,
        10,
        addr15
      );

      await multipleCreateSale(
        assets3D.address,
        [11],
        Utils.toWei("8"),
        [1],
        0,
        60,
        addr16
      );

      const sales = await root.viewSalesByAsset(assets3D.address, 11, 200);

      console.log("Salesss", sales);

      for (let j = 0; j < sales.length; j++) {
        console.log("Test", Utils.fromWei(sales[j]["price"]));
      }
    });
    it("Should PASS createSale() BASIC Order", async () => {
      await root
        .connect(addr9)
        .createSale(assets3D.address, [20], Utils.toWei("0.01"), [1], 0);
    });
    it("Should PASS createSale() BASIC Order", async () => {
      await root
        .connect(addr9)
        .createSale(assets3D.address, [20], Utils.toWei("0.01"), [1], 0);
    });
    it("Should PASS createSale() BASIC Order", async () => {
      await root
        .connect(addr9)
        .createSale(assets3D.address, [20], Utils.toWei("0.01"), [1], 0);
    });
    it("Should PASS createSale() BASIC Order", async () => {
      await root
        .connect(addr9)
        .createSale(assets3D.address, [20], Utils.toWei("0.01"), [1], 0);
    });
    it("Should PASS createSale() BASIC Order", async () => {
      await root
        .connect(addr9)
        .createSale(assets3D.address, [20], Utils.toWei("0.01"), [1], 0);
    });
    it("Should PASS transferFrom() 5 item id 20 to addr19", async () => {
      await assets3D
        .connect(addr9)
        .safeTransferFrom(addr9.address, addr17.address, 20, 5, "0x");
    });
    it("Should PASS viewSmallestId() id20", async () => {
      const smallestId = await root.viewSalesByAsset(assets3D.address, 20, 6);
      console.log("smallestId", smallestId);
    });
    it("Should PASS createSale() BASIC Order", async () => {
      await root
        .connect(addr5)
        .createSale(assets3D.address, [20], Utils.toWei("0.01"), [1], 0);
    });
    it("Should PASS viewSmallestId() id20", async () => {
      const smallestId = await root.viewSalesByAsset(assets3D.address, 20, 6);
      console.log("smallestId", smallestId);
    });
  });
  describe("ERC721 - Tests", () => {
    it("Should PASS createSale() BASIC Order", async () => {
      await root
        .connect(addr1)
        .createSale(ovrLand.address, [1], Utils.toWei("0.01"), [1], 0);
    });
    it("Should FAIL createSale() BASIC Order", async () => {
      await expect(
        root
          .connect(addr1)
          .createSale(ovrLand.address, [1], Utils.toWei("0.01"), [1], 0)
      ).to.be.revertedWith("S11");
    });
    it("Should FAIL createSale() BASIC Order", async () => {
      await expect(
        root
          .connect(addr3)
          .createSale(ovrLand.address, [1], Utils.toWei("0.01"), [1], 0)
      ).to.be.revertedWith("S09");
    });
    it("Should FAIL cancelSale() BASIC Order", async () => {
      const salesCount = (await root.salesCount()) - 1;
      await expect(
        root.connect(addr2).cancelSale(salesCount)
      ).to.be.revertedWith("S15");
    });
    it("Should PASS cancelSale() BASIC Order", async () => {
      const salesCount = (await root.salesCount()) - 1;
      await root.connect(addr1).cancelSale(salesCount);
    });
    it("Should PASS createSale() BASIC Order", async () => {
      await root
        .connect(addr1)
        .createSale(ovrLand.address, [1], Utils.toWei("0.01"), [1], 0);
    });
    it("Should PASS buy() BASIC Order", async () => {
      const salesCount = (await root.salesCount()) - 1;
      await root.connect(addr2).buy(salesCount, 1);
    });
  });
});
