// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

interface ITemplate is IERC165 {
    function name() external pure returns (string memory);
    function image(uint256 tokenId) external view returns (string memory);
}