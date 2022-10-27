//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import {ItemType} from "./Enums.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/IERC1155Upgradeable.sol";

library SaleOrderRequires {
    function saleCreationChecks(
        uint256 price,
        uint256[] calldata tokenId,
        uint256[] memory amount,
        ItemType tokenType,
        bool onAuction,
        address token,
        address sender
    ) internal view {
        require(price != 0, "S01");

        require(tokenId.length == amount.length, "S06");

        if (tokenType == ItemType.ERC721) {
            require(!onAuction, "S07");
            require(tokenId.length == 1, "S08");
            // prettier-ignore
            require(IERC721Upgradeable(token).ownerOf(tokenId[0]) == sender, "S09");
            // prettier-ignore
            require(IERC721Upgradeable(token).getApproved(tokenId[0]) == address(this) || IERC721Upgradeable(token).isApprovedForAll(sender, address(this)), "S10");
        } else {
            uint256 amountTemp = amount[0];
            for (uint256 i = 0; i < tokenId.length; i++) {
                // prettier-ignore
                require(IERC1155Upgradeable(token).balanceOf(sender, tokenId[i]) >= amount[i], "S12");
                require(amountTemp == amount[i], "S13");
            }
            require(tokenId.length <= 10, "S14");
            // prettier-ignore
            require(IERC1155Upgradeable(token).isApprovedForAll(sender, address(this)), "S10");
        }
    }
}
