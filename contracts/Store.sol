//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";

import "./Allowed.sol";

import {Auction, Sale, Offer} from "../libraries/Structs.sol";
import {ItemType} from "../libraries/Enums.sol";

contract Store is Allowed, ReentrancyGuardUpgradeable, PausableUpgradeable {
    function __Store_init(address _feeReceiver, uint256 _fee) internal {
        __initialize_Allowed();
        __Pausable_init();
        feeReceiver = _feeReceiver;
        fee = _fee;
    }

    uint256 public fee; // 0.5%
    address public feeReceiver;

    // Auctions
    mapping(address => mapping(uint256 => Auction)) public bidOrders;
    mapping(address => mapping(uint256 => bool)) public auctionStarted;

    // Sales
    uint256 public salesCount;
    mapping(uint256 => Sale) public sales;
    mapping(address => mapping(uint256 => uint256)) public saleIndexes721;
    uint256[] public _freeIndexesSell;

    // Offers
    uint256 public offersCount;
    mapping(uint256 => Offer) public offers;
    mapping(address => uint256[]) public accountOffers;
    uint256[] public freeIndexes;

    function assetType(address token) public view virtual returns (ItemType) {
        return allowedAddresses[token].tokenType;
    }
}
