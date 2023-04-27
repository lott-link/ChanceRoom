// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IFactory {
    function ownerOf(uint256 chanceRoomId) external view returns(address creator);
    function tempLatestVersion(string memory tempName) external view returns(address implAddr, uint256 version);
    function tempVersionAddr(string memory tempName, uint256 version) external view returns(address tempAddr);
    function addImplementation(address implAddr) external;
}