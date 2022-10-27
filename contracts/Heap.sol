// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
//import IStore
import "../interfaces/IStore.sol";

// Author: Jacopo Mosconi

/*
implementation of binary min heap
what is it (wikipedia): https:// en.wikipedia.org/wiki/Binary_heap
explination: a heap is a binary tree where the parent node is always smaller than the child nodes
the root node is always the smallest node
the heap is stored in an array, the parent node is stored at index i, 
the left child is stored at index 2*i and the right child is stored at index 2*i+1
to insert a node, we add it to the end of the array and then swap it with 
its parent node until it is smaller than its parent node
to delete a node, we swap it with the last node in the array and then swap 
it with its smallest child node until it is smaller than both of its child nodes

Logarithmic Time Complexity:
insertNode is O(log n)
updateNode is O(log n)
deleteNode is O(log n)
deleteMin is O(log n)
getMin is O(1)
*/

contract Heap is AccessControlUpgradeable {
    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    IStore public store;

    //token addr => token id => price
    mapping(address => mapping(uint256 => Node[])) heapPrice;
    //token address => tokenId => price => index
    mapping(address => mapping(uint256 => mapping(uint256 => uint256))) heapIndex;

    struct Node {
        uint256 sellOrderIndex;
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
        uint256 sellOrderIndex
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        if (heapPrice[token][tokenId].length == 0) {
            initHeap(token, tokenId);
        }
        heapPrice[token][tokenId].push(Node(sellOrderIndex, price));
        uint256 index = heapPrice[token][tokenId].length - 1;
        heapIndex[token][tokenId][sellOrderIndex] = index;
        heapifyUp(token, tokenId, index);
    }

    // delete node
    function deleteNode(
        address token,
        uint256 tokenId,
        uint256 sellOrderIndex
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        uint256 index = heapIndex[token][tokenId][sellOrderIndex];
        uint256 lastIndex = heapPrice[token][tokenId].length - 1;
        Node memory lastNode = heapPrice[token][tokenId][lastIndex];
        heapPrice[token][tokenId][index] = lastNode;
        heapPrice[token][tokenId].pop();
        heapIndex[token][tokenId][lastNode.sellOrderIndex] = index;
        delete heapIndex[token][tokenId][sellOrderIndex];
        heapifyDown(token, tokenId, index);
    }

    // update node
    function updateNode(
        address token,
        uint256 tokenId,
        uint256 price,
        uint256 sellOrderIndex
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        uint256 index = heapIndex[token][tokenId][sellOrderIndex];
        heapPrice[token][tokenId][index].price = price;
        heapifyUp(token, tokenId, index);
        heapifyDown(token, tokenId, index);
    }

    // get min node
    function getMinNode(address token, uint256 tokenId)
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
        uint256 sellOrderIndex
    ) public view returns (Node memory) {
        uint256 index = heapIndex[token][tokenId][sellOrderIndex];
        return heapPrice[token][tokenId][index];
    }

    /**
     * @dev heapify up: compare with parent node, if smaller, swap
     */

    function heapifyUp(
        address token,
        uint256 tokenId,
        uint256 index
    ) internal {
        uint256 parentIndex = index / 2;
        while (parentIndex > 0) {
            if (
                heapPrice[token][tokenId][parentIndex].price >
                heapPrice[token][tokenId][index].price
            ) {
                Node memory temp = heapPrice[token][tokenId][parentIndex];
                heapPrice[token][tokenId][parentIndex] = heapPrice[token][
                    tokenId
                ][index];
                heapPrice[token][tokenId][index] = temp;
                heapIndex[token][tokenId][
                    heapPrice[token][tokenId][parentIndex].sellOrderIndex
                ] = parentIndex;
                heapIndex[token][tokenId][
                    heapPrice[token][tokenId][index].sellOrderIndex
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
            uint256 minIndex = index;
            if (
                heapPrice[token][tokenId][minIndex].price >
                heapPrice[token][tokenId][leftChildIndex].price
            ) {
                minIndex = leftChildIndex;
            }
            if (
                rightChildIndex < heapPrice[token][tokenId].length &&
                heapPrice[token][tokenId][minIndex].price >
                heapPrice[token][tokenId][rightChildIndex].price
            ) {
                minIndex = rightChildIndex;
            }
            if (minIndex != index) {
                Node memory temp = heapPrice[token][tokenId][minIndex];
                heapPrice[token][tokenId][minIndex] = heapPrice[token][tokenId][
                    index
                ];
                heapPrice[token][tokenId][index] = temp;
                heapIndex[token][tokenId][
                    heapPrice[token][tokenId][minIndex].sellOrderIndex
                ] = minIndex;
                heapIndex[token][tokenId][
                    heapPrice[token][tokenId][index].sellOrderIndex
                ] = index;
                index = minIndex;
                leftChildIndex = index * 2;
                rightChildIndex = index * 2 + 1;
            } else {
                break;
            }
        }
    }

    function getSmallest(
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

        //if there is only 2 node, return the min(since the first node is 0)

        if (heapPrice[token][tokenId].length == 2) {
            nodes[0] = heapPrice[token][tokenId][1].sellOrderIndex;
            return nodes;
        }

        Node[] memory heap = heapPrice[token][tokenId];
        for (uint256 i = 1; i <= length; i++) {
            (address seller, , , , , ) = store.sales(heap[1].sellOrderIndex);

            if (IERC1155(token).balanceOf(seller, tokenId) > 0) {
                nodes[i - 1] = heap[1].sellOrderIndex;
            } else {
                i--;
                if (heap.length == 2) {
                    break;
                }
            }

            heap[1] = heap[heap.length - 1];
            assembly {
                mstore(heap, sub(mload(heap), 1))
            }

            uint256 index = 1;
            uint256 leftChildIndex = index * 2;
            uint256 rightChildIndex = index * 2 + 1;
            while (leftChildIndex < heap.length) {
                uint256 minIndex = index;
                if (heap[minIndex].price > heap[leftChildIndex].price) {
                    minIndex = leftChildIndex;
                }
                if (
                    rightChildIndex < heap.length &&
                    heap[minIndex].price > heap[rightChildIndex].price
                ) {
                    minIndex = rightChildIndex;
                }
                if (minIndex != index) {
                    Node memory temp = heap[minIndex];
                    heap[minIndex] = heap[index];
                    heap[index] = temp;
                    index = minIndex;
                    leftChildIndex = index * 2;
                    rightChildIndex = index * 2 + 1;
                } else {
                    break;
                }
            }
        }
        //delete from nodes if it is 0
        uint256 count = 0;
        for (uint256 i = 0; i < nodes.length; i++) {
            if (nodes[i] != 0) {
                count++;
            }
        }
        uint256[] memory newNodes = new uint256[](count);
        uint256 j = 0;
        for (uint256 i = 0; i < nodes.length; i++) {
            if (nodes[i] != 0) {
                newNodes[j] = nodes[i];
                j++;
            }
        }

        return newNodes;
    }

    //function admin to set store address
    function addStore(IStore _store) public onlyRole(DEFAULT_ADMIN_ROLE) {
        store = _store;
    }

    //function to set default admin role
    function addAdminRole(address _admin) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _grantRole(DEFAULT_ADMIN_ROLE, _admin);
    }
}
