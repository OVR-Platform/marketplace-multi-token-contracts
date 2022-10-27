//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "./TokenUtils.sol";
import "./Store.sol";

import "../libraries/AuctionsUtils.sol";
import {Auction, Bidder} from "../libraries/Structs.sol";
import "../libraries/Events.sol";
import {_now} from "../libraries/Utils.sol";

contract Auctions is Store, TokenUtils {
    function createAuction(
        address _token,
        uint256 _tokenId,
        uint256 _startingPrice,
        uint256 _startTime,
        uint256 _endTime
    ) external nonReentrant whenNotPaused {
        onlyAllowedAddress(_token);
        address saleOrderSeller = sales[saleIndexes721[_token][_tokenId]]
            .seller;
        AuctionsUtils.auctionCreationChecks(
            _startTime,
            _endTime,
            bidOrders[_token][_tokenId].seller,
            allowedAddresses[_token].tokenType,
            IERC721Upgradeable(_token).ownerOf(_tokenId),
            _msgSender(),
            saleOrderSeller // attuale venditore se esiste
        );
        // create auction
        Auction storage newOrder = bidOrders[_token][_tokenId];
        newOrder.seller = _msgSender();
        newOrder.token = _token;
        newOrder.tokenId = _tokenId;
        newOrder.price = _startingPrice;
        newOrder.creationTime = _now();
        newOrder.startTime = _startTime;
        newOrder.endTime = _endTime;
        auctionStarted[_token][_tokenId] = true;

        // prettier-ignore
        emit Events.AuctionCreated(_msgSender(), _token, _tokenId, _startingPrice, _startTime, _endTime);
    }

    function isApprovedForAll(address token, uint256 tokenId)
        internal
        view
        returns (bool)
    {
        return
            IERC721Upgradeable(token).isApprovedForAll(
                bidOrders[token][tokenId].seller,
                address(this)
            );
    }

    //bid on auction
    function bid(
        address token,
        uint256 tokenId,
        uint256 price
    ) external nonReentrant {
        onlyAllowedAddress(token);
        require(auctionStarted[token][tokenId], "A01");

        uint256 amount;
        if (bidOrders[token][tokenId].Bidders.length == 0) {
            amount = bidOrders[token][tokenId].price;
        } else {
            amount = bidOrders[token][tokenId]
                .Bidders[bidOrders[token][tokenId].Bidders.length - 1]
                .bidAmount;
        }

        AuctionsUtils.bidChecks(
            bidOrders[token][tokenId],
            price,
            amount,
            IERC721Upgradeable(token).ownerOf(tokenId),
            IERC721Upgradeable(token).getApproved(tokenId),
            isApprovedForAll(token, tokenId),
            IERC20Upgradeable(TokenUtils.OVRToken).balanceOf(_msgSender())
        );

        //create bid
        Bidder memory newBidder = Bidder(_msgSender(), price, _now());
        bidOrders[token][tokenId].Bidders.push(newBidder);
        bidOrders[token][tokenId].BiddersIndex[_msgSender()] =
            bidOrders[token][tokenId].Bidders.length -
            1;
        bidOrders[token][tokenId].price = price;

        //emit event
        emit Events.Bidded(
            bidOrders[token][tokenId].seller,
            _msgSender(),
            token,
            tokenId,
            price,
            _now()
        );
    }

    function completeAuction(address token, uint256 tokenId)
        external
        nonReentrant
        whenNotPaused
    {
        onlyAllowedAddress(token);
        AuctionsUtils.auctionCompletionChecks(
            bidOrders[token][tokenId].endTime,
            IERC721Upgradeable(token).ownerOf(tokenId),
            bidOrders[token][tokenId].seller
        );

        uint256 fees = (bidOrders[token][tokenId].price * fee) / (10000);
        uint256 finalAmount = bidOrders[token][tokenId].price - (fees);

        // transfer tokens to seller/owner
        TokenUtils.transferFromERC20(
            bidOrders[token][tokenId]
                .Bidders[bidOrders[token][tokenId].Bidders.length - 1]
                .bidder,
            bidOrders[token][tokenId].seller,
            finalAmount
        );

        // transfer fees to feeReceiver
        TokenUtils.transferFromERC20(
            bidOrders[token][tokenId]
                .Bidders[bidOrders[token][tokenId].Bidders.length - 1]
                .bidder,
            feeReceiver,
            fees
        );

        TokenUtils.transferERC721(
            token,
            bidOrders[token][tokenId].seller,
            bidOrders[token][tokenId]
                .Bidders[bidOrders[token][tokenId].Bidders.length - 1]
                .bidder,
            tokenId
        );

        // delete auction
        delete bidOrders[token][tokenId];
        auctionStarted[token][tokenId] = false;

        // prettier-ignore
        emit Events.AuctionEnded(bidOrders[token][tokenId].seller, token, tokenId, bidOrders[token][tokenId].price);
    }

    function cancelAuction(address token, uint256 tokenId) external {
        onlyAllowedAddress(token);

        AuctionsUtils.cancelAuctionRequires(
            bidOrders[token][tokenId].seller,
            _msgSender(),
            IERC721Upgradeable(token).ownerOf(tokenId),
            auctionStarted[token][tokenId],
            bidOrders[token][tokenId].endTime
        );

        //delete auction
        delete bidOrders[token][tokenId];
        delete auctionStarted[token][tokenId];

        //emit event
        emit Events.AuctionDeleted(_msgSender(), token, tokenId, _now());
    }

    function getAuctionDetails(address token, uint256 tokenId)
        public
        view
        returns (
            address seller,
            uint256 price,
            uint256 endTime,
            uint256 length,
            Bidder[] memory bidders
        )
    {
        seller = bidOrders[token][tokenId].seller;
        price = bidOrders[token][tokenId].price;
        endTime = bidOrders[token][tokenId].endTime;
        length = bidOrders[token][tokenId].Bidders.length;
        bidders = bidOrders[token][tokenId].Bidders;
    }
}
