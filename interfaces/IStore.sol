// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

interface IStore {
    function _freeIndexesSell(uint256) external view returns (uint256);

    function accountOffers(address, uint256) external view returns (uint256);

    function addAllowedAddress(address _address, uint8 tokenType) external;

    function allowedAddresses(address)
        external
        view
        returns (
            address addr,
            uint8 tokenType,
            bool allowed
        );

    function assetType(address token) external view returns (uint8);

    function auctionStarted(address, uint256) external view returns (bool);

    function bidOrders(address, uint256)
        external
        view
        returns (
            address seller,
            address token,
            uint256 tokenId,
            uint256 price,
            uint256 creationTime,
            uint256 startTime,
            uint256 endTime
        );

    function fee() external view returns (uint256);

    function feeReceiver() external view returns (address);

    function freeIndexes(uint256) external view returns (uint256);

    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    function grantRole(bytes32 role, address account) external;

    function hasRole(bytes32 role, address account)
        external
        view
        returns (bool);

    function offers(uint256)
        external
        view
        returns (
            address buyer,
            address token,
            uint256 tokenId,
            uint256 price,
            uint256 orderTime,
            uint256 indexOrder
        );

    function offersCount() external view returns (uint256);

    function paused() external view returns (bool);

    function renounceRole(bytes32 role, address account) external;

    function revokeRole(bytes32 role, address account) external;

    function saleIndexes721(address, uint256) external view returns (uint256);

    function sales(uint256)
        external
        view
        returns (
            address seller,
            address token,
            uint256 price,
            uint8 orderType,
            uint256 orderTime,
            uint256 indexOrder
        );

    function salesCount() external view returns (uint256);

    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
