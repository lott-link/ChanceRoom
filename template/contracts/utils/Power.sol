// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

library Power {

    function power(address addr) internal pure returns(uint256 p) {
        bytes20 byti = bytes20(addr);
        while (byti[p/2] == 0x0) {
            p += 2;
        }
        if(byti[p/2] < 0x10) p++;
    }

}
