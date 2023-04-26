// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../interfaces/IFactory.sol";

abstract contract OwnableFactory {

    IFactory immutable public ChanceRoomFactory;

    constructor(IFactory chanceRoomFactory) {
        ChanceRoomFactory = chanceRoomFactory;
    }
    
    modifier onlyOwner() {
        require(
            msg.sender == owner(), 
            "OwnableFactory: only owner of the contract can call this function"
        );
        _;
    }

    function owner() public view returns(address) {
        return ChanceRoomFactory.ownerOf(uint256(uint160(address(this))));
    }
}