//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "./TokenUtils.sol";
import "./Store.sol";

import {Offer} from "../libraries/Structs.sol";
import {_now} from "../libraries/Utils.sol";
import "../libraries/Events.sol";
import {ItemType, OrderType} from "../libraries/Enums.sol";

contract Offers is Store, TokenUtils {
    function __Offers_init(uint256 _count) internal {
        offersCount = _count;
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
        uint256 accountOffersLength = accountOffers[_msgSender()].length;

        if (accountOffersLength > 0) {
            //check if the user has already a Offer for this token ID
            // prettier-ignore
            for (uint16 i = 0; i < accountOffersLength; i++) {
            // prettier-ignore
                if (offers[accountOffers[_msgSender()][i]].token == _token) {
                    require(
                        offers[accountOffers[_msgSender()][i]]
                            .tokenId != _tokenId,
                        "O07"
                    );
                }
            }
        }

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
        accountOffers[_msgSender()].push(index);

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

        delete offers[index];
        freeIndexes.push(index);
        for (uint16 i = 0; i < accountOffers[_msgSender()].length; i++) {
            if (accountOffers[_msgSender()][i] == index) {
                // prettier-ignore
                accountOffers[_msgSender()][i] = accountOffers[_msgSender()][accountOffers[_msgSender()].length - 1];
                accountOffers[_msgSender()].pop();
                break;
            }
        }

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

        delete offers[index];
        freeIndexes.push(index);
        // prettier-ignore
        for (uint256 i = 0;  i < accountOffers[offers[index].buyer].length; i++) {
            if (accountOffers[offers[index].buyer][i] == index) {
                // prettier-ignore
                accountOffers[offers[index].buyer][i] = accountOffers[offers[index].buyer][accountOffers[offers[index].buyer].length - 1];
                accountOffers[offers[index].buyer].pop();
                break;
            }
        }

        TokenUtils.transferERC20(_msgSender(), toSpend);

        TokenUtils.transferERC20(feeReceiver, fees);
    }
}
