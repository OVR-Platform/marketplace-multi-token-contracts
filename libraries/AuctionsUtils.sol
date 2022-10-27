//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;


import {ItemType} from "./Enums.sol";
import {_now} from "./Utils.sol";
import {Auction, Bidder} from "../libraries/Structs.sol";

library AuctionsUtils {
    function isValidOrder(bool onAuction, address seller) internal pure {
        require(onAuction, "A01");
        require(seller != address(0), "A01");
    }

    function bidChecks(
        Auction storage auction,
        uint256 price,
        uint256 lastBidPrice,
        address ownerOf,
        address getApproved,
        bool isApprovedAll,
        uint256 balanceOf
    ) internal view {

        require(auction.startTime <= _now() && _now() <= auction.endTime, "A10");
        uint256 tenPercent = lastBidPrice / 10;
        uint256 tenPercentPlusLastBidPrice = lastBidPrice + tenPercent;
        require(price >= tenPercentPlusLastBidPrice, "A11");
        require(ownerOf == auction.seller, "A12");
        isApproved(getApproved, isApprovedAll);
        require(balanceOf > price, "A14");
    }

    function auctionCompletionChecks(
        uint256 endTime,
        address ownerOf,
        address seller
    ) internal view {
        require(endTime <= _now(), "A15");
        require(ownerOf == seller, "A12");
    }

    function isApproved(address getApproved, bool isApprovedAll) internal view {
        require(getApproved == address(this) || isApprovedAll, "A13");
    }

    function auctionCreationChecks(
        uint256 startTime,
        uint256 endTime,
        address seller,
        ItemType tokenType,
        address ownerOf,
        address sender,
        address saleSeller
    ) internal view {
        require(tokenType == ItemType.ERC721, "A02");
 
        require(startTime >= _now(), "A04");
        require(endTime > startTime, "A05");
        require(seller == address(0), "A06");
        require(ownerOf == sender, "A08");
        require(saleSeller == address(0), "A09"); // Shold not be placed also as sale
    }

    function cancelAuctionRequires(
        address seller,
        address msgSender,
        address ownerOf,
        bool onAuction,
        uint256 endTime
    ) internal view {
        require(endTime > _now(), "A03");
        isValidOrder(onAuction, seller);
        require(ownerOf == msgSender, "A16");
    }
}
