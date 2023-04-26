// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/ITemplate.sol";

abstract contract TemplateView {

    function _image(address templateAddress, uint256 tokenId)
        internal
        view
        returns(string memory)
    {
        (bool success, bytes memory data) = address(this).staticcall(
            abi.encodeWithSelector(
                ITemplate.image.selector,
                templateAddress,
                tokenId
            )
        );

        require(success, "unable to generate the template");
        return(abi.decode(data, (string)));
    }

    fallback() external {
        if(msg.sender == address(this)){
            bytes4 imgSelector = bytes4(msg.data[:4]);
            (address tempAddr, uint256 tokenId) = 
            abi.decode(msg.data[4:], (address, uint256));
            if(imgSelector == ITemplate.image.selector) {

                (bool success, bytes memory data) = 
                tempAddr.delegatecall(abi.encodeWithSelector(imgSelector, tokenId));
                assembly {
                    switch success
                        // delegatecall returns 0 on error.
                        case 0 { revert(add(data, 32), returndatasize()) }
                        default { return(add(data, 32), returndatasize()) }
                }
            }
        }
    }
}