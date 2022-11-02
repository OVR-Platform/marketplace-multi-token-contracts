/* eslint-disable no-unused-vars */
/* eslint-disable no-undef */
const { expect } = require("chai");
const { ethers, upgrades, web3 } = require("hardhat");
const { time } = require("@openzeppelin/test-helpers");

const Utils = require("./utils");

const feeReceiver = "0x00000000000B186EbeF1AC9a27C7eB16687ac2A9";
const feePercent = 500;
let token,
  Token,
  root,
  Root,
  heap,
  Heap,
  heapOffers,
  HeapOffers,
  erc1155,
  Erc1155,
  erc721,
  Erc721;

// ONLY AUCTIONS TESTS

describe("Auctions - TEST", () => {
  describe("Current Block", () => {
    it("Should be 0", async () => {
      currentBlock = await time.latest();
      console.debug(
        "\t\t\tCurrent Block Time",
        Utils.displayTime(Number(currentBlock.toString()))
      );
    });
    //create auction tests
    describe("Create Auction", () => {
      //should deploy token
      it("Should deploy token", async () => {
        Token = await ethers.getContractFactory("Token");
        //deploy without proxy

        token = await Token.deploy();
        await token.deployed();
        console.debug("\t\t\tToken deployed to:", token.address);
      });
      //should deploy heap
      it("Should deploy heap", async () => {
        Heap = await ethers.getContractFactory("HeapSales");
        //deploy without proxy

        heap = await Heap.deploy();
        await heap.deployed();
        console.debug("\t\t\tHeap deployed to:", heap.address);
      });

      it("Should deploy heap", async () => {
        HeapOffers = await ethers.getContractFactory("HeapOffers");
        //deploy without proxy

        heapOffers = await HeapOffers.deploy();
        await heapOffers.deployed();
        console.debug("\t\t\tHeapOffers deployed to:", heapOffers.address);
      });
      //should deploy erc1155
      it("Should deploy erc1155", async () => {
        Erc1155 = await ethers.getContractFactory("Assets3D");
        //deploy without proxy

        erc1155 = await Erc1155.deploy();
        await erc1155.deployed();
        console.debug("\t\t\tERC1155 deployed to:", erc1155.address);
      });
      //should deploy erc721
      it("Should deploy erc721", async () => {
        Erc721 = await ethers.getContractFactory("OVRLand");
        //deploy without proxy

        erc721 = await Erc721.deploy();
        await erc721.deployed();
        console.debug("\t\t\tERC721 deployed to:", erc721.address);
      });

      it("Should depoy root", async () => {
        //deploy contract root and link libraries
        Root = await ethers.getContractFactory("Root");

        root = await upgrades.deployProxy(Root, [
          feeReceiver,
          feePercent,
          token.address,
          heap.address,
          heapOffers.address,
          1,
          1,
        ]);
        await root.deployed();
        // Add Heap Admin Role to Root
        await heapOffers.addAdminRole(root.address);
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
      //should allow erc1155
      it("Should allow erc1155", async () => {
        await root.addAllowedAddress(erc1155.address, 1);
        console.log("\t\t\tERC1155 allowed");
      });
      //should allow erc721
      it("Should allow erc721", async () => {
        await root.addAllowedAddress(erc721.address, 0);
        console.log("\t\t\tERC721 allowed");
      });
      //should mint erc1155
      it("Should mint erc1155", async () => {
        await erc1155.mint(owner.address, 1, 5, "0x");
        console.log("\t\t\tERC1155: minted 5 tokens with id 1");
      });
      //should mint erc721
      it("Should mint erc721", async () => {
        await erc721.mint(owner.address, 1);
        console.log("\t\t\tERC721: minted 1 token with id 1");
      });
      //transfer token to addr1, addr2 and addr3
      it("Should transfer token to addr1, addr2 and addr3", async () => {
        await token.transfer(addr1.address, Utils.toWei("100"));
        await token.transfer(addr2.address, Utils.toWei("100"));
        await token.transfer(addr3.address, Utils.toWei("100"));
        console.log("\t\t\tToken transferred to addr1, addr2 and addr3");
      });
      //should create auction
      it("Should create auction", async () => {
        //console.log DAY from utils.js
        now = await time.latest();
        start = now.add(time.duration.hours(1));
        endTime = now.add(time.duration.days(10));
        console.log("now: ", now.toString());
        console.debug(
          "\t\t\tCurrent Time",
          Utils.displayTime(Number(now.toString()))
        );
        console.log("\t\t\tAuction start time:", Utils.displayTime(start));
        console.log("\t\t\tAuction end time:", Utils.displayTime(endTime));

        //owner setApprovalToAll erc721 to root
        await erc721.setApprovalForAll(root.address, true);

        await root.createAuction(
          erc721.address,
          1,
          web3.utils.toWei("1"),
          Number(BigInt(start).toString()),
          Number(BigInt(endTime).toString())
        );
        console.log("\t\t\tERC721: created auction with id 1");
      });
      it("Should get auction details", async () => {
        auction = await root.getAuctionDetails(erc721.address, 1);
        console.log("\t\t\tERC721: auction details", auction);
      });
      //addr1, addr2, addr3 should approve token to root
      it("Should approve token to root", async () => {
        await token.connect(addr1).approve(root.address, Utils.toWei("10000"));
        await token.connect(addr2).approve(root.address, Utils.toWei("10000"));
        await token.connect(addr3).approve(root.address, Utils.toWei("10000"));
        console.log("\t\t\tToken approved to root");
      });
      //move time forward 2 day
      it("Should move time forward 2 day", async () => {
        await time.increase(2 * Utils.DAY);
        console.log("\t\t\tTime moved forward 1 day");
      });
      it("Should bid on auction", async () => {
        await root.connect(addr1).bid(erc721.address, 1, web3.utils.toWei("2"));
        console.log("\t\t\tERC721: addr1 bid on auction with id 1");
      });
      it("Should bid on auction", async () => {
        await root.connect(addr2).bid(erc721.address, 1, web3.utils.toWei("3"));
        console.log("\t\t\tERC721: addr2 bid on auction with id 1");
      });
      it("Should bid on auction", async () => {
        await root.connect(addr3).bid(erc721.address, 1, web3.utils.toWei("4"));
        console.log("\t\t\tERC721: addr3 bid on auction with id 1");
      });
      it("Should bid on auction", async () => {
        await root.connect(addr1).bid(erc721.address, 1, web3.utils.toWei("5"));
        console.log("\t\t\tERC721: addr1 bid on auction with id 1");
      });
      it("Should get auction details", async () => {
        auction = await root.getAuctionDetails(erc721.address, 1);
        //show seller, price, endTime, length
        console.log("\t\t\tERC721: auction details", {
          Seller: auction[0],
          Price: auction[1].toString(),
          EndTime: auction[2].toString(),
          NumberOfBidders: auction[3].toString(),
        });

        for (let i = 0; i < auction[4].length; i++) {
          console.log("\t\t\tBidder", {
            bidderAddress: auction[4][i][0].toString(),
            bidAmount: auction[4][i][1].toString(),
            bidTime: auction[4][i][2].toString(),
          });
        }
      });
      it("Should cancel auction", async () => {
        await root.cancelAuction(erc721.address, 1);
        console.log("\t\t\tERC721: auction cancelled");
      });
      //try to complete auction, should fail 'cause auction is cancelled
      it("Should try to complete auction, should fail", async () => {
        await expect(
          root.completeAuction(erc721.address, 1)
        ).to.be.revertedWith("A12");
        console.log("\t\t\tERC721: auction complete failed");
      });
      it("Should create auction", async () => {
        //console.log DAY from utils.js
        now = await time.latest();
        start = now.add(time.duration.hours(1));
        endTime = now.add(time.duration.days(10));
        console.debug(
          "\t\t\tCurrent Time",
          Utils.displayTime(Number(now.toString()))
        );
        console.log("\t\t\tAuction start time:", Utils.displayTime(start));
        console.log("\t\t\tAuction end time:", Utils.displayTime(endTime));

        await root.createAuction(
          erc721.address,
          1,
          web3.utils.toWei("1"),
          Number(BigInt(start).toString()),
          Number(BigInt(endTime).toString())
        );
        console.log("\t\t\tERC721: created auction with id 1");
      });
      it("Should get auction details", async () => {
        auction = await root.getAuctionDetails(erc721.address, 1);
        console.log("\t\t\tERC721: auction details", auction);
      });

      it("Should move time forward 2 day", async () => {
        await time.increase(2 * Utils.DAY);
        console.log("\t\t\tTime moved forward 1 day");
      });
      it("Should bid on auction", async () => {
        await root.connect(addr1).bid(erc721.address, 1, web3.utils.toWei("2"));
        console.log("\t\t\tERC721: addr1 bid on auction with id 1");
      });
      it("Should bid on auction", async () => {
        await root.connect(addr2).bid(erc721.address, 1, web3.utils.toWei("3"));
        console.log("\t\t\tERC721: addr2 bid on auction with id 1");
      });
      it("Should bid on auction", async () => {
        await root.connect(addr3).bid(erc721.address, 1, web3.utils.toWei("4"));
        console.log("\t\t\tERC721: addr3 bid on auction with id 1");
      });
      it("Should get auction details", async () => {
        auction = await root.getAuctionDetails(erc721.address, 1);
        //show seller, price, endTime, length
        console.log("\t\t\tERC721: auction details", {
          Seller: auction[0],
          Price: auction[1].toString(),
          EndTime: auction[2].toString(),
          NumberOfBidders: auction[3].toString(),
        });

        for (let i = 0; i < auction[4].length; i++) {
          console.log("\t\t\tBidder", {
            bidderAddress: auction[4][i][0].toString(),
            bidAmount: auction[4][i][1].toString(),
            bidTime: auction[4][i][2].toString(),
          });
        }
      });
      //move time forward until auction ends
      it("Should move time forward until auction ends", async () => {
        await time.increase(10 * Utils.DAY);
        console.log("\t\t\tTime moved forward 10 day");
      });
      //complete auction from bidder
      it("Should complete auction", async () => {
        //balance token and erc721 of owner
        let ownerTokenBalance = await token.balanceOf(owner.address);
        let ownerERC721Balance = await erc721.balanceOf(owner.address);
        console.log(
          "\t\t\tERC721: owner token balance",
          ownerTokenBalance.toString()
        );
        console.log(
          "\t\t\tERC721: owner erc721 balance",
          ownerERC721Balance.toString()
        );
        //balance token and erc721 of addr3
        let addr3TokenBalance = await token
          .connect(addr3)
          .balanceOf(addr3.address);
        let addr3ERC721Balance = await erc721
          .connect(addr3)
          .balanceOf(addr3.address);
        console.log(
          "\t\t\tERC721: addr3 token balance",
          addr3TokenBalance.toString()
        );
        console.log(
          "\t\t\tERC721: addr3 erc721 balance",
          addr3ERC721Balance.toString()
        );
        await root.connect(addr3).completeAuction(erc721.address, 1);
        console.log("\t\t\tERC721: auction completed");

        let ownerTokenBalanceAfter = await token.balanceOf(owner.address);
        let ownerERC721BalanceAfter = await erc721.balanceOf(owner.address);
        console.log(
          "\t\t\tERC721: owner token balance",
          ownerTokenBalanceAfter.toString()
        );
        console.log(
          "\t\t\tERC721: owner erc721 balance",
          ownerERC721BalanceAfter.toString()
        );
        //balance token and erc721 of addr3
        let addr3TokenBalanceAfter = await token
          .connect(addr3)
          .balanceOf(addr3.address);
        let addr3ERC721BalanceAfter = await erc721
          .connect(addr3)
          .balanceOf(addr3.address);
        console.log(
          "\t\t\tERC721: addr3 token balance",
          addr3TokenBalanceAfter.toString()
        );
        console.log(
          "\t\t\tERC721: addr3 erc721 balance",
          addr3ERC721BalanceAfter.toString()
        );
      });
      it("Should get auction details", async () => {
        auction = await root.getAuctionDetails(erc721.address, 1);
        //show seller, price, endTime, length
        console.log("\t\t\tERC721: auction details", {
          Seller: auction[0],
          Price: auction[1].toString(),
          EndTime: auction[2].toString(),
          NumberOfBidders: auction[3].toString(),
        });

        for (let i = 0; i < auction[4].length; i++) {
          console.log("\t\t\tBidder", {
            bidderAddress: auction[4][i][0].toString(),
            bidAmount: auction[4][i][1].toString(),
            bidTime: auction[4][i][2].toString(),
          });
        }
      });
      //create 2 identical auctions , the second one should fail
      it("Should create 2 identical auctions", async () => {
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
          .connect(addr3)
          .createAuction(
            erc721.address,
            1,
            web3.utils.toWei("1"),
            Number(BigInt(start).toString()),
            Number(BigInt(endTime).toString())
          );
        console.log("\t\t\tERC721: created auction with id 1");
        await expect(
          root
            .connect(addr3)
            .createAuction(
              erc721.address,
              1,
              web3.utils.toWei("1"),
              Number(BigInt(start).toString()),
              Number(BigInt(endTime).toString())
            )
        ).to.be.revertedWith("A06");
        console.log("\t\t\tERC721: Failed to create another auction with id 1");
      });
    });
  });
});
