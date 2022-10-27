// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

interface IHeap {
    struct Node {
        uint256 sellOrderIndex;
        uint256 price;
    }
    event RoleAdminChanged(
        bytes32 indexed role,
        bytes32 indexed previousAdminRole,
        bytes32 indexed newAdminRole
    );
    event RoleGranted(
        bytes32 indexed role,
        address indexed account,
        address indexed sender
    );
    event RoleRevoked(
        bytes32 indexed role,
        address indexed account,
        address indexed sender
    );

    function DEFAULT_ADMIN_ROLE() external view returns (bytes32);

    function deleteNode(
        address token,
        uint256 tokenId,
        uint256 sellOrderIndex
    ) external;

    function getMinNode(address token, uint256 tokenId)
        external
        view
        returns (Node memory);

    function getNode(
        address token,
        uint256 tokenId,
        uint256 sellOrderIndex
    ) external view returns (Node memory);

    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    function getSmallest(
        address token,
        uint256 tokenId,
        uint8 length
    ) external view returns (uint256[] memory);

    function grantRole(bytes32 role, address account) external;

    function hasRole(bytes32 role, address account)
        external
        view
        returns (bool);

    function insertNode(
        address token,
        uint256 tokenId,
        uint256 price,
        uint256 sellOrderIndex
    ) external;

    function renounceRole(bytes32 role, address account) external;

    function revokeRole(bytes32 role, address account) external;

    function setDefaultAdminRole(address _admin) external;

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

    function updateNode(
        address token,
        uint256 tokenId,
        uint256 price,
        uint256 sellOrderIndex
    ) external;
}
