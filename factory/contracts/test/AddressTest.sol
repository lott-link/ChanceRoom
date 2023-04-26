// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract AddressTest {
    
    function test(bytes20 a) public pure returns(uint256 ans) {
        ans = uint160(a) / 87112285931760246646623899502532662132736;

    }

    function uin160(bytes20 a) public pure returns(uint160 uin) {
        uin = uint160(a);
    }
}