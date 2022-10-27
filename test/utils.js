const { ethers } = require("hardhat");

module.exports.displayTime = (unixTime) => {
  const date = new Date(unixTime * 1000).toLocaleString("it-IT");
  return date;
};

module.exports.fromWei = (stringValue) =>
  ethers.utils.formatUnits(stringValue, 18);
module.exports.toWei = (value) => ethers.utils.parseEther(value);

module.exports.MONTH = 2592000;
module.exports.DAY = 86400;

beforeEach(async () => {
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

module.exports.offerLogger = (offer) => {
  console.debug("Offer", {
    buyer: offer.buyer,
    token: offer.token,
    tokenId: offer.tokenId.toString(),
    price: this.fromWei(offer.price),
    orderTime: offer.orderTime.toString(),
    index: offer.indexOrder.toString(),
  });
};
