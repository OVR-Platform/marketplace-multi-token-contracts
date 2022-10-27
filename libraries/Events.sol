//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

library Events {
    event AuctionCreated(
        address indexed seller,
        address indexed token,
        uint256 indexed tokenId,
        uint256 price,
        uint256 startTime,
        uint256 endTime
    );

    event AuctionDeleted(
        address indexed seller,
        address indexed token,
        uint256 indexed tokenId,
        uint256 timestamp
    );

    event Bidded(
        address indexed seller,
        address indexed bidder,
        address indexed token,
        uint256 tokenId,
        uint256 bidAmount,
        uint256 bidTime
    );

    event AuctionEnded(
        address indexed seller,
        address indexed token,
        uint256 indexed tokenId,
        uint256 price
    );

    event OfferCreated(
        address indexed buyer,
        address token,
        uint256 indexed tokenId,
        uint256 price,
        uint256 indexOrder,
        uint256 orderTime
    );

    event OfferDeleted(address indexed buyer, uint256 indexOrder);

    event Bought(
        uint256 indexed indexOrder,
        address indexed buyer,
        uint256 indexed amount,
        uint256 fulfillTime
    );

    event Fulfilled(
        uint256 indexed indexOrder,
        address indexed buyer,
        uint256 indexed amount,
        uint256 remainingAmount,
        uint256 fulfillTime
    );

    event SaleCreated(
        address indexed seller,
        address token,
        uint256[] indexed tokenId,
        uint256 price,
        uint256 indexOrder,
        uint256[] indexed amount,
        uint256 orderType,
        uint256 orderTime
    );

    event SaleDeleted(
        address indexed seller,
        address token,
        uint256[] indexed tokenId,
        uint256 indexed indexOrder
    );
}
