//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import {ItemType, OrderType} from "./Enums.sol";

struct AllowedAddress {
    address addr;
    ItemType tokenType;
    bool allowed;
}

struct Sale {
    address seller;
    address token;
    uint256[] tokenId;
    uint256 price;
    uint256[] amount;
    OrderType orderType;
    uint256 orderTime;
    uint256 indexOrder;
}

struct Offer {
    address buyer;
    address token;
    uint256 tokenId;
    uint256 price;
    uint256 orderTime;
    uint256 indexOrder;
}

struct Auction {
    address seller;
    Bidder[] Bidders;
    mapping(address => uint256) BiddersIndex;
    address token;
    uint256 tokenId;
    uint256 price;
    uint256 creationTime;
    uint256 startTime;
    uint256 endTime;
}

struct Bidder {
    address bidder;
    uint256 bidAmount;
    uint256 bidTime;
}
