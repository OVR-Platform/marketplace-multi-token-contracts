//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import "./Sales.sol";
import "./Offers.sol";
import "./Auctions.sol";

contract Root is UUPSUpgradeable, Offers, Auctions, Sales {
    function initialize(
        address _feeReceiver,
        uint16 _feePercentage,
        address _token,
        address _heapAddress,
        uint256 _offersCount,
        uint256 _salesCount
    ) external initializer {
        __Offers_init(_offersCount);
        __Sales_init(_heapAddress, _salesCount);
        __Store_init(_feeReceiver, _feePercentage);
        __TokenUtils_init(_token);
    }

    function pause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
    }

    function _authorizeUpgrade(address)
        internal
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
    {}
}
