//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;


import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/IERC1155Upgradeable.sol";

import "./TokenUtils.sol";
import "./Store.sol";

import "../interfaces/IHeap.sol";

import "../libraries/Events.sol";
import "../libraries/SalesLibrary.sol";
import {Sale} from "../libraries/Structs.sol";
import {_now} from "../libraries/Utils.sol";
import {ItemType, OrderType} from "../libraries/Enums.sol";

contract Sales is Store, TokenUtils {
    function __Sales_init(address _heap, uint256 _count) internal {
        salesCount = _count;
        heap = IHeap(_heap);
    }

    IHeap public heap;

    function viewSalesByAsset(
        address token,
        uint256 tokenId,
        uint8 amount
    ) public view returns (Sale[] memory) {
        if (assetType(token) == ItemType.ERC721) {
            Sale[] memory order;
            order[0] = sales[saleIndexes721[token][tokenId]];
            return order;
        }

        uint256[] memory indexes = heap.getSmallest(token, tokenId, amount);
        Sale[] memory orders = new Sale[](indexes.length);

        for (uint256 i = 0; i < indexes.length; i++) {
            orders[i] = sales[indexes[i]];
        }

        return orders;
    }

    /**
     * @dev Create a sell order
     * @param token address of token to sell
     * @param tokenId array of ids of token to sell (can be also 1 id)
     * @param price price for item in wei
     *    if token is erc721 price is for the nft
     *    if token is erc1155 price is for 1 token
     *    if token is erc1155 and it's an advanced order
     *    price is for 1 token of each id
     * @param amount array of amount of token to sell (can be also 1 amount)
     *    if token is erc721 amount is set to 1
     *    if token is erc1155 amount is for each id consequently
     * @param orderType type of order (simple or advanced = 0 or 1)
     */
    function createSale(
        address token,
        uint256[] calldata tokenId,
        uint256 price,
        uint256[] memory amount,
        OrderType orderType
    ) external whenNotPaused {
        onlyAllowedAddress(token);

        bool onAuction_ = auctionStarted[token][tokenId[0]];

        // prettier-ignore
        SaleOrderRequires.saleCreationChecks(price, tokenId, amount, assetType(token), onAuction_, token, _msgSender());

        uint256 index;
        if (_freeIndexesSell.length > 0) {
            index = _freeIndexesSell[_freeIndexesSell.length - 1];
            _freeIndexesSell.pop();
        } else {
            index = salesCount;
            salesCount++;
        }

        if (assetType(token) == ItemType.ERC721) amount[0] = 1;
        if (orderType == OrderType.BASIC) {
            require(tokenId.length == 1, "S02");
            // if ERC721 save index in saleIndexes721 else save order in heap
            if (assetType(token) == ItemType.ERC721) {
                require(saleIndexes721[token][tokenId[0]] == 0 ||
                 sales[saleIndexes721[token][tokenId[0]]].seller != _msgSender(), "S11");

                saleIndexes721[token][tokenId[0]] = index;
                
            } else {
                heap.insertNode(token, tokenId[0], price, index);
            }
        } else {
            // Order Type check
            require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "S18");
            require(tokenId.length > 1, "S03");
            require(assetType(token) == ItemType.ERC1155, "S04");
        }

        // prettier-ignore
        sales[index] = Sale(_msgSender(), token, tokenId, price, amount, orderType, _now(), index);
        // prettier-ignore
        emit Events.SaleCreated(_msgSender(), token, tokenId, price, index, amount, uint256(orderType), _now());
    }

    /**
     * @dev Cancel a sell order
     * @param index index of order to cancel
     */
    function cancelSale(uint256 index) external {
        require(sales[index].seller == _msgSender(), "S15");

        _cancelSale(index);
        // prettier-ignore
        emit Events.SaleDeleted(_msgSender(), sales[index].token, sales[index].tokenId, index);
    }

    function _cancelSale(uint256 index) internal {
        if (assetType(sales[index].token) == ItemType.ERC721) {
            // prettier-ignore
            delete saleIndexes721[sales[index].token][sales[index].tokenId[0]];
        } else {
            //delete from heap
            // prettier-ignore
            heap.deleteNode(sales[index].token, sales[index].tokenId[0], index);
            delete sales[index];
        }

        _freeIndexesSell.push(index);
    }

    /**
     * @dev Complete a sellOrder
     * @param index the index of the sellOrder
     * @param amount the amount wanted to buy (0 for all, if ERC721 it's useless)
     */

    function buy(uint256 index, uint256 amount) external whenNotPaused {
     
        require(sales[index].seller != _msgSender(), "O02");
        require(sales[index].seller != address(0), "O03");
        for (uint256 i = 0; i < sales[index].tokenId.length; i++) {
            require(amount <= sales[index].amount[i], "O04");
        }
        uint256 toSpend;
        if (assetType(sales[index].token) == ItemType.ERC721) {
            // prettier-ignore

            require(
                IERC721Upgradeable(sales[index].token).ownerOf(
                    sales[index].tokenId[0]
                ) == sales[index].seller,
                "O05"
            );
            // prettier-ignore
            TokenUtils.transferERC721(sales[index].token, sales[index].seller, _msgSender(), sales[index].tokenId[0]);
            toSpend = sales[index].price;
        } else {
            for (uint256 i = 0; i < sales[index].tokenId.length; i++) {
                if (
                    IERC1155Upgradeable(sales[index].token).balanceOf(
                        sales[index].seller,
                        sales[index].tokenId[i]
                    ) <= sales[index].amount[i]
                ) {
                    revert("O06");
                }
            }

            uint256[] memory newAmount = new uint256[](1);

            if (amount != 0) {
                newAmount[0] = amount;
                for (uint256 i = 0; i < sales[index].tokenId.length; i++) {
                    sales[index].amount[i] -= amount;
                }
                toSpend = amount * sales[index].price;
            } else {
                toSpend = sales[index].amount[0] * sales[index].price;
                newAmount[0] = sales[index].amount[0];
            }

            // prettier-ignore
            TokenUtils.transferERC1155Batch(sales[index].token, sales[index].seller, _msgSender(), sales[index].tokenId, newAmount);
        }

        uint256 feeAmount = (toSpend * fee) / 10000;
        toSpend = toSpend - feeAmount;
        //send fees to feeReceiver
        TokenUtils.transferFromERC20(_msgSender(), feeReceiver, feeAmount);
        //send token to seller
        TokenUtils.transferFromERC20(
            _msgSender(),
            sales[index].seller,
            toSpend
        );
        if (sales[index].amount[0] == 0) {
            _cancelSale(index);
            emit Events.Bought(index, _msgSender(), amount, _now());
        } else {
            // prettier-ignore
            emit Events.Fulfilled(index, _msgSender(), amount, sales[index].amount[0], _now());
        }
    }
}
