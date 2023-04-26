// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.7;
pragma abicoder v2;

import '@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol';
import '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';

interface IwERC20 {
    function deposit() external payable;
    function withdraw(uint256 amount) external;
    function balanceOf(address _owner) external view returns(uint256);
}

interface IpegSwap {
    function swap(uint256 amount, address source, address target) external;
}

// on polygon matic mainnet
contract Swapper {

    ISwapRouter internal constant uniSwap = ISwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);
    IpegSwap internal constant pegSwap = IpegSwap(0xAA1DC356dc4B18f30C347798FD5379F3D77ABC5b);
    address internal constant wMATIC = 0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270;
    address internal constant LINK_ERC20 = 0x53E0bca35eC356BD5ddDFebbD1Fc0fD03FaBad39;
    address internal constant LINK_ERC677 = 0xb0897686c545045aFc77CF20eC7A532E3120E0F1;

    // For this example, we will set the pool fee to 0.3%.
    uint24 internal constant poolFee = 3000;

    function swap_MATIC_LINK677(uint256 amountIn) internal {

        uint256 amount_LINK20 = swap_MATIC_LINK20(amountIn);

        TransferHelper.safeApprove(LINK_ERC20, address(pegSwap), amount_LINK20);

        swap_LINK20_677(amount_LINK20);
    }

    function swap_MATIC_LINK677(uint256 amountOut, uint256 amountInMaximum) internal {

        swap_MATIC_LINK20(amountOut, amountInMaximum);

        TransferHelper.safeApprove(LINK_ERC20, address(pegSwap), amountOut);

        swap_LINK20_677(amountOut);
    }

    function swap_MATIC_LINK20(uint256 amountIn) internal returns(uint256 amountOut) {
        IwERC20 wm = IwERC20(wMATIC);
        wm.deposit{value: amountIn - wm.balanceOf(address(this))}();

        TransferHelper.safeApprove(wMATIC, address(uniSwap), amountIn);

        ISwapRouter.ExactInputSingleParams memory params =
            ISwapRouter.ExactInputSingleParams({
                tokenIn: wMATIC,
                tokenOut: LINK_ERC20,
                fee: poolFee,
                recipient: address(this),
                deadline: block.timestamp,
                amountIn: amountIn,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });

        amountOut = uniSwap.exactInputSingle(params);
    }

    function swap_MATIC_LINK20(uint256 amountOut, uint256 amountInMaximum) internal returns(uint256 amountIn) {
        IwERC20 wm = IwERC20(wMATIC);
        wm.deposit{value: amountInMaximum - wm.balanceOf(address(this))}();

        TransferHelper.safeApprove(wMATIC, address(uniSwap), amountInMaximum);

        ISwapRouter.ExactOutputSingleParams memory params =
            ISwapRouter.ExactOutputSingleParams({
                tokenIn: wMATIC,
                tokenOut: LINK_ERC20,
                fee: poolFee,
                recipient: address(this),
                deadline: block.timestamp,
                amountOut: amountOut,
                amountInMaximum: amountInMaximum,
                sqrtPriceLimitX96: 0
            });

        amountIn = uniSwap.exactOutputSingle(params);
    }

    function swap_LINK20_677(uint256 amount) internal {
        pegSwap.swap(amount, LINK_ERC20, LINK_ERC677);
    }
}