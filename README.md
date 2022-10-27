# Marketplace ERC1155-ERC721

---

# Installation

```js
nvm use
npm install
```

# 🔑 ENV

Create an `.env` file on root. Take a look to `.env.example`

```
PRIVATE_KEY = ""
ETHERSCAN_API_KEY = ""
COINMARKETCAP_API_KEY = ""
ALCHEMY_KEY = ""
```

# 🧪 TESTS

```javascript
npx hardhat test
```

# ➡️ DEPLOY

```javascript
// Check before deploy
npx hardhat run scripts/deploy.js --network mainnet
```

# ↩️ UPGRADE

```javascript
// Check initialize before upgrade
npx hardhat run scripts/upgrade.js --network mainnet
```

# 📖 Doc

The Marketplace is responsible for managing the trades made by users of ERC721-ERC1155 assets.

The types of orders that can be placed within the marketplace are as follows:

- Sales (ERC721-ERC721)
- Buy Offers (ERC721-ERC1155)
- Auctions (ERC721 only)

The `Root.sol` file manages auctions that are reserved only for type 721 assets.
All trades uses only `ERC20` OVR Token as payment method.

## SALES

Possibility to sell a ERC721 at X price or sell Y copies of a given ERC1155 at X price per item.

Advanced Sales (only Admin): Build packs of different items (1 Shirt + 1 Pants + 2 Hats) but same Contract Address. We will have the contract Clothes.

The owner of the assets after sale creation could delete it.

- ERC721: buyer accepts the sale price of an NFT, and decides to pay the specified amount to buy it

- ERC1155: option to buy the whole order or only part of it

Ex. ERC1155
User A offers 28 red hats for sale at 7 OVR each

Case A:
User B buys all 28 hats at once paying 28\*7 = 196 OVR

Case B:

- User B purchases 5 hats by paying 5\*7 = 35 OVR
- User C buys 1 hat by paying 1\*7 = 7 OVR
- User D purchases 10 hats by paying 10\*7 = 70 OVR
- User E purchases 10 hats by paying 10\*7 = 70 OVR
- User F purchases 2 hats by paying 2\*7 = 14 OVR

At the end of F's purchase, 5+1+10+2 = 28 hats will have been sold, consequently the sale order is concluded.

## AUCTIONS

Auctions will only be available for ERC721, the auction will have a starting price, a starting date, and an ending date.

A user can only start an auction if the NFT has not already been put up for sale previously (auctions and sale for the same NFT cannot coexist, either it is put up for direct sale, or it is put up for sale via auction).

Interested users can place bids, which of course must always be higher than those made previously (10% higher)

Once an auction is created, it is not possible to end it, same for user-made bids.

## BUY OFFERS

It will be possible to make purchase offers for single ERC721 and for ERC1155 also specifying a desired quantity.

The user will then have the possibility to cancel it, in case it is a purchase order for an amount > 1, and a part of the order has already been completed, obviously only the part of the order not yet completed will be canceled.

### Acceptance of purchase offers:

In the case of acceptance of the purchase offer for a 721, once the owner accepts the NFT ⇔ OVR exchange will take place

In the case of an 1155, anyone will be able to participate in the completion of the purchase, just like in the direct sales process, users who own that asset are not obliged to complete the entire order, but also only a part

Ex.
User A makes an offer to purchase 5 shirts by offering 6 OVR each

- User B sells him 1, thus receiving 1 \_ 6 = 6 OVR
- User C sells him 3, thus receiving 3 \_ 6 = 18 OVR
- User D sells him 2, thus receiving 1 \* 6 = 6 OVR

At the end of the sale with D, the purchase offer will be concluded and will be canceled

---

## Warning Messages

### Auctions

- A01: auction does not exist
- A02: token type should be 721
- A03: auction has ended
- A04: start time should be greater than now
- A05: end time should be greater than start time
- A06: auction already exists
- A07: price should be greater than 0
- A08: you are not the owner of the token
- A09: sell order already exists
- A10: Auction not started yet
- A11: bid price should be greater than current price
- A12: seller not owner of token
- A13: Contract is not approved to transfer token
- A14: insufficient balance
- A15: Auction has not ended
- A16: you are not the seller

### Offers

- O01: This buy order does not exist
- O02: insufficient balance
- O03: Seller cannot buy his own item or invalid Seller
- O04: Amount is too high
- O05: Seller is not the owner of the token
- O06: Seller does not have enough tokens
- O07: You already have a Offer for this token, edit it instead
- O08: You are not the owner of this buy order
- O09: amount requested is higher than the amount of the buy order
- O10: not valid token

### Sales

- S01: Price cannot be 0
- S02: tokenId.length must be 1 for basic order
- S03: tokenIds less than 2 for advanced order
- S04: token must be ERC1155 for advanced order
- S05: Invalid order type
- S06: tokenId and amount length mismatch
- S07: NFT on auction
- S08: ERC721 can only have one tokenId
- S09: Not the owner
- S10: Not approved
- S11: tokenId already on sale with order index: {index}
- S12: Not enough balance
- S13: To fulfill the order, the amount must be the same for each token in the pack
- S14: ERC1155 must have a maximum of 10 tokens
- S15: Not the seller
- S16: amount length mismatch
- S17: invalid token type
- S18: should be admin
