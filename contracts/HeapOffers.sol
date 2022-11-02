// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

// Author: Jacopo Mosconi
// Binary Max Heap

contract HeapOffers is AccessControlUpgradeable {
    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    //token addr => token id => price
    mapping(address => mapping(uint256 => Node[])) heapPrice;
    //token address => tokenId => price => index
    mapping(address => mapping(uint256 => mapping(uint256 => uint256))) heapIndex;

    struct Node {
        uint256 offerOrderIndex;
        uint256 price;
    }

    function initHeap(address token, uint256 tokenId) internal {
        heapPrice[token][tokenId].push(Node(0, 0));
    }

    // insert node
    function insertNode(
        address token,
        uint256 tokenId,
        uint256 price,
        uint256 offerOrderIndex
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        if (heapPrice[token][tokenId].length == 0) {
            initHeap(token, tokenId);
        }
        heapPrice[token][tokenId].push(Node(offerOrderIndex, price));
        uint256 index = heapPrice[token][tokenId].length - 1;
        heapIndex[token][tokenId][offerOrderIndex] = index;
        heapifyUp(token, tokenId, index);
    }

    // delete node
    function deleteNode(
        address token,
        uint256 tokenId,
        uint256 offerOrderIndex
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        uint256 index = heapIndex[token][tokenId][offerOrderIndex];
        uint256 lastIndex = heapPrice[token][tokenId].length - 1;
        Node memory lastNode = heapPrice[token][tokenId][lastIndex];
        heapPrice[token][tokenId][index] = lastNode;
        heapPrice[token][tokenId].pop();
        heapIndex[token][tokenId][lastNode.offerOrderIndex] = index;
        delete heapIndex[token][tokenId][offerOrderIndex];
        heapifyDown(token, tokenId, index);
    }

    // get max node
    function getMaxNode(address token, uint256 tokenId)
        public
        view
        returns (Node memory)
    {
        return heapPrice[token][tokenId][1];
    }

    // get node
    function getNode(
        address token,
        uint256 tokenId,
        uint256 offerOrderIndex
    ) public view returns (Node memory) {
        uint256 index = heapIndex[token][tokenId][offerOrderIndex];
        return heapPrice[token][tokenId][index];
    }

    /**
     * @dev heapify up: compare with parent node, if bigger, swap
     */

    function heapifyUp(
        address token,
        uint256 tokenId,
        uint256 index
    ) internal {
        uint256 parentIndex = index / 2;
        while (parentIndex > 0) {
            if (
                heapPrice[token][tokenId][parentIndex].price <
                heapPrice[token][tokenId][index].price
            ) {
                Node memory temp = heapPrice[token][tokenId][parentIndex];
                heapPrice[token][tokenId][parentIndex] = heapPrice[token][
                    tokenId
                ][index];
                heapPrice[token][tokenId][index] = temp;
                heapIndex[token][tokenId][
                    heapPrice[token][tokenId][parentIndex].offerOrderIndex
                ] = parentIndex;
                heapIndex[token][tokenId][
                    heapPrice[token][tokenId][index].offerOrderIndex
                ] = index;
                index = parentIndex;
                parentIndex = index / 2;
            } else {
                break;
            }
        }
    }

    /**
     * @dev heapify down: compare with left and right child, swap with the smaller one
     */

    function heapifyDown(
        address token,
        uint256 tokenId,
        uint256 index
    ) internal {
        uint256 leftChildIndex = index * 2;
        uint256 rightChildIndex = index * 2 + 1;
        while (leftChildIndex < heapPrice[token][tokenId].length) {
            uint256 maxIndex = index;
            if (
                heapPrice[token][tokenId][maxIndex].price <
                heapPrice[token][tokenId][leftChildIndex].price
            ) {
                maxIndex = leftChildIndex;
            }
            if (
                rightChildIndex < heapPrice[token][tokenId].length &&
                heapPrice[token][tokenId][maxIndex].price <
                heapPrice[token][tokenId][rightChildIndex].price
            ) {
                maxIndex = rightChildIndex;
            }
            if (maxIndex != index) {
                Node memory temp = heapPrice[token][tokenId][maxIndex];
                heapPrice[token][tokenId][maxIndex] = heapPrice[token][tokenId][
                    index
                ];
                heapPrice[token][tokenId][index] = temp;
                heapIndex[token][tokenId][
                    heapPrice[token][tokenId][maxIndex].offerOrderIndex
                ] = maxIndex;
                heapIndex[token][tokenId][
                    heapPrice[token][tokenId][index].offerOrderIndex
                ] = index;
                index = maxIndex;
                leftChildIndex = index * 2;
                rightChildIndex = index * 2 + 1;
            } else {
                break;
            }
        }
    }

    function getBestAssets(
        address token,
        uint256 tokenId,
        uint8 length
    ) public view returns (uint256[] memory) {
        uint256[] memory nodes;

        if (heapPrice[token][tokenId].length == 1) {
            return nodes;
        }

        //if lenth is bigger than heap length, create an array with heap length
        if (length > heapPrice[token][tokenId].length - 1) {
            nodes = new uint256[](heapPrice[token][tokenId].length - 1);
            length = uint8(heapPrice[token][tokenId].length - 1);
        } else {
            //otherwise create an array with length
            nodes = new uint256[](length);
        }

        //if there is only 2 node, return the max(since the first node is 0)

        if (heapPrice[token][tokenId].length == 2) {
            nodes[0] = heapPrice[token][tokenId][1].offerOrderIndex;
            return nodes;
        }

        Node[] memory heap = heapPrice[token][tokenId];
        for (uint256 i = 1; i <= length; i++) {
            nodes[i - 1] = heap[1].offerOrderIndex;
            heap[1] = heap[heap.length - 1];
            assembly {
                mstore(heap, sub(mload(heap), 1))
            }

            uint256 index = 1;
            uint256 leftChildIndex = index * 2;
            uint256 rightChildIndex = index * 2 + 1;
            while (leftChildIndex < heap.length) {
                uint256 maxIndex = index;
                if (heap[maxIndex].price < heap[leftChildIndex].price) {
                    maxIndex = leftChildIndex;
                }
                if (
                    rightChildIndex < heap.length &&
                    heap[maxIndex].price < heap[rightChildIndex].price
                ) {
                    maxIndex = rightChildIndex;
                }
                if (maxIndex != index) {
                    Node memory temp = heap[maxIndex];
                    heap[maxIndex] = heap[index];
                    heap[index] = temp;
                    index = maxIndex;
                    leftChildIndex = index * 2;
                    rightChildIndex = index * 2 + 1;
                } else {
                    break;
                }
            }
        }

        return nodes;
    }

    //function to set default admin role
    function addAdminRole(address _admin) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _grantRole(DEFAULT_ADMIN_ROLE, _admin);
    }
}
