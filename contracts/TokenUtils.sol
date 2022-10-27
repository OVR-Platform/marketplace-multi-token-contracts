//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

//interfaces
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/IERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract TokenUtils is Initializable {
    address public OVRToken;

    function __TokenUtils_init(address _token) internal initializer {
        OVRToken = _token;
    }

    function transferFromERC20(
        address from,
        address to,
        uint256 amount
    ) internal {
        IERC20Upgradeable(OVRToken).transferFrom(from, to, amount);
    }

    function transferERC20(address to, uint256 amount) internal {
        IERC20Upgradeable(OVRToken).transfer(to, amount);
    }

    function transferERC1155(
        address token,
        address from,
        address to,
        uint256 id,
        uint256 amount
    ) internal {
        IERC1155Upgradeable(token).safeTransferFrom(from, to, id, amount, "");
    }

    function transferERC721(
        address token,
        address from,
        address to,
        uint256 id
    ) internal {
        IERC721Upgradeable(token).safeTransferFrom(from, to, id);
    }

    function transferERC1155Batch(
        address token,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal {
        IERC1155Upgradeable(token).safeBatchTransferFrom(
            from,
            to,
            ids,
            amounts,
            ""
        );
    }

    function transferERC721Batch(
        address token,
        address from,
        address to,
        uint256[] memory ids
    ) internal {
        for (uint256 i = 0; i < ids.length; i++) {
            IERC721Upgradeable(token).safeTransferFrom(from, to, ids[i]);
        }
    }
}
