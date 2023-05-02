// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

interface IChanceRoom is IERC165 {

    function lockedNFT() external view returns(
        string memory name,
        address addr, 
        uint256 id
    );
    function tempInfo() external view returns(
        string memory name,
        address addr
    );
    function implInfo() external view returns (
        string memory name,
        address addr
    );
    function info() external view returns(
        string memory _name,
        string memory _rule,
        uint256 _initTime
    );
    function status() external view returns(string memory s1, string memory s2);
}