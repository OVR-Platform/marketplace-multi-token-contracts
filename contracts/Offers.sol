//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "./TokenUtils.sol";
import "./Store.sol";

import {Offer} from "../libraries/Structs.sol";
import {_now} from "../libraries/Utils.sol";
import "../libraries/Events.sol";
import {ItemType, OrderType} from "../libraries/Enums.sol";
import "../interfaces/IHeap.sol";

contract Offers is Store, TokenUtils {
    IHeap public heapOffer;

    function __Offers_init(uint256 _count, address _heap) internal {
        offersCount = _count;
        heapOffer = IHeap(_heap);
    }

    function viewOffersByAsset(
        address token,
        uint256 tokenId,
        uint8 amount
    ) public view returns (Offer[] memory) {
        uint256[] memory indexes = heapOffer.getBestAssets(
            token,
            tokenId,
            amount
        );
        Offer[] memory orders = new Offer[](indexes.length);

        for (uint256 i = 0; i < indexes.length; i++) {
            orders[i] = offers[indexes[i]];
        }

        return orders;
    }

    function buyOrderExist(uint256 index) private view {
        require(offers[index].token != address(0), "O01");
    }

    /**
     * @dev Create a buy order
     * @param _token the address of the token
     * @param _tokenId the id of the token
     * @param _price the price of the token (or for single item if 1155)
     */
    function createOffer(
        address _token,
        uint256 _tokenId,
        uint256 _price
    ) external nonReentrant whenNotPaused {
        onlyAllowedAddress(_token);
        require(!accountOffers[_token][_tokenId][_msgSender()], "O07");

        uint256 index;

        if (freeIndexes.length == 0) {
            index = offersCount;
            offersCount++;
        } else {
            index = freeIndexes[freeIndexes.length - 1];
            freeIndexes.pop();
        }

        TokenUtils.transferFromERC20(_msgSender(), address(this), _price);

        // prettier-ignore
        offers[index] = Offer(_msgSender(), _token, _tokenId, _price, _now(), index);
        accountOffers[_token][_tokenId][_msgSender()] = true;
        heapOffer.insertNode(_token, _tokenId, _price, index);

        // prettier-ignore
        emit Events.OfferCreated( _msgSender(), _token, _tokenId, _price, index, _now());
    }

    /**
     * @dev Delete a buy order
     * @param index the index of the buy order
     */
    function deleteOffer(uint256 index) external {
        buyOrderExist(index);
        require(offers[index].buyer == _msgSender(), "O08");
        address token = offers[index].token;
        uint256 tokenId = offers[index].tokenId;
        accountOffers[token][tokenId][_msgSender()] = false;

        delete offers[index];
        freeIndexes.push(index);
        heapOffer.deleteNode(token, tokenId, index);

        TokenUtils.transferERC20(_msgSender(), offers[index].price);

        emit Events.OfferDeleted(_msgSender(), index);
    }

    /**
     * @dev complete a buy order
     * @param index the index of the buy order
     */
    function fulfillOffer(uint256 index) external nonReentrant whenNotPaused {
        buyOrderExist(index);
        // prettier-ignore
        uint256 fees = (offers[index].price * fee) / 10000;
        uint256 toSpend = offers[index].price - fees;
        // prettier-ignore
        if (allowedAddresses[offers[index].token].tokenType == ItemType.ERC721) {
            //token must be not on Auction
           require(auctionStarted[offers[index].token][offers[index].tokenId] == false, "O09");
            
            // prettier-ignore
            TokenUtils.transferERC721(offers[index].token, _msgSender(), offers[index].buyer, offers[index].tokenId);
        } else {
            // prettier-ignore
            TokenUtils.transferERC1155(offers[index].token, _msgSender(), offers[index].buyer, offers[index].tokenId, 1);
        }

        address token = offers[index].token;
        uint256 tokenId = offers[index].tokenId;
        accountOffers[token][tokenId][offers[index].buyer] = false;

        delete offers[index];
        freeIndexes.push(index);
        heapOffer.deleteNode(token, tokenId, index);

        TokenUtils.transferERC20(_msgSender(), toSpend);

        TokenUtils.transferERC20(feeReceiver, fees);
    }
}
