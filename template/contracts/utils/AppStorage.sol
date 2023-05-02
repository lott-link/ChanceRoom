// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

library AppStorage {

    bytes32 constant APP_STORAGE_POSITION = keccak256("APP_STORAGE_POSITION");

    function layout() internal pure returns (Layout storage l) {
        bytes32 position = APP_STORAGE_POSITION;
        assembly {
            l.slot := position
        }
    }

    struct Layout {
        VarUint256 Uint256;
        VarAddress Address;
        VarBool Bool;
        // VarInt256 Int256;
    }

    struct VarUint256 {
        uint256 initTime;
        uint256 nftId;
        uint256 maximumTicket;
        uint256 soldTickets;
        uint256 deadLine;
        uint256 ticketPrice;
        uint256 winnerId;
    }

    struct VarAddress {
        address nftAddr;
        address tempAddr;
    }

    struct VarBool {
        bool triggered;
        bool refunded;
    }

    // struct VarInt256 {
    //     int256 priceRate;
    // }
    
}
