// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

abstract contract VRFConsumer is VRFConsumerBase {
    
    bytes32 internal keyHash;
    uint256 internal linkFee;

    event VRFResponse(bytes32 requestId, uint256 randomness);

    /**
     * Constructor inherits VRFConsumerBase
     * 
     * Network: MATIC MAINNET
     * Chainlink VRF Coordinator address: 0x3d2341ADb2D31f1c5530cDC622016af293177AE0
     * LINK token address:                0xb0897686c545045aFc77CF20eC7A532E3120E0F1
     * Key Hash: 0xf86195cf7690c55907b2b611ebb7343a6f649bff128701cc542f0569e2c549da
     */
    constructor() 
        VRFConsumerBase(
            0x3d2341ADb2D31f1c5530cDC622016af293177AE0, // VRF Coordinator
            0xb0897686c545045aFc77CF20eC7A532E3120E0F1  // LINK Token
        )
    {
        keyHash = 0xf86195cf7690c55907b2b611ebb7343a6f649bff128701cc542f0569e2c549da;
        linkFee = 0.0001 * 10 ** 18; // 0.0001 LINK (Varies by network)
    }

    
    function _getRandomNumber() internal returns(bytes32 requestId){
        require(LINK.balanceOf(address(this)) >= linkFee, "Not enough LINK");
        requestId = requestRandomness(keyHash, linkFee);
        return requestId;
    }
    
    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        _select(randomness);
        emit VRFResponse(requestId, randomness);
    }

    function _select(uint256 randomness) internal virtual{}
}
