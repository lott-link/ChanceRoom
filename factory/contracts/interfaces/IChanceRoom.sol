// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

interface IChanceRoom is IERC165 {

    // function name() external pure returns (string memory);
    function template() external view returns(
        string memory name,
        address addr
    );
    function nft() external view returns(
        string memory name,
        address addr, 
        uint256 id
    );
    function implementation() external view returns (
        string memory name,
        address addr
    );
    function info() external view returns(
        string memory _name,
        string memory _rule
    );

    function status() external view returns(string memory s1, string memory s2);
}