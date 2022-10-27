//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

import {AllowedAddress} from "../libraries/Structs.sol";
import {ItemType} from "../libraries/Enums.sol";

contract Allowed is AccessControlUpgradeable {
    mapping(address => AllowedAddress) public allowedAddresses;

    function __initialize_Allowed() internal onlyInitializing {
        __AccessControl_init();

        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    function onlyAllowedAddress(address _address) internal view {
        require(allowedAddresses[_address].allowed, "ALL");
    }

    /**
     * @dev Add address to allowed list
     * @param _address address to add
     * @param tokenType token type
     * @notice note tokenType => 0 = ERC721 | 1 = ERC1155
     */

    function addAllowedAddress(address _address, ItemType tokenType)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        allowedAddresses[_address] = AllowedAddress(_address, tokenType, true);
    }
}
