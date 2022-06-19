// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

interface IERC721 {
    function ownerOf(uint256 tokenId) external view returns (address owner);
}
