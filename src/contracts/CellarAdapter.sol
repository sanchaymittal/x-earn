// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IUniswapV3Router} from "./interfaces/external/IUniswapV3Router.sol";

contract CellarAdapter {
    using SafeERC20 for ERC20;

    address internal receiver =
        address(0x75e4DD0587663Fce5B2D9aF7fbED3AC54342d3dB);

    // ERC20 internal TEST = ERC20(0xeDb95D8037f769B72AAab41deeC92903A98C9E16);
    // ERC20 internal WMatic = ERC20(0x9c3C9283D3e44854697Cd22D3Faa240Cfb032889);

    /// GOERLI
    ERC20 internal TEST = ERC20(0x7ea6eA49B0b0Ae9c5db7907d139D9Cd3439862a1);
    ERC20 internal WETH = ERC20(0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6);

    address internal constant uniV3Router =
        0xE592427A0AEce92De3Edee1F18E0157C05861564;
    IUniswapV3Router public immutable uniswapV3Router; // 0xE592427A0AEce92De3Edee1F18E0157C05861564

    // ========================================== CONSTRUCTOR ==========================================

    constructor() {
        uniswapV3Router = IUniswapV3Router(uniV3Router);
    }

    /**
     * @notice Attempted to perform a swap that reverted without a message.
     */
    error SwapRouter__SwapReverted();

    /**
     * @notice Attempted to perform a swap with mismatched assetIn and swap data.
     * @param actual the address encoded into the swap data
     * @param expected the address passed in with assetIn
     */
    error SwapRouter__AssetInMisMatch(address actual, address expected);

    /**
     * @notice Attempted to perform a swap with mismatched assetOut and swap data.
     * @param actual the address encoded into the swap data
     * @param expected the address passed in with assetIn
     */
    error SwapRouter__AssetOutMisMatch(address actual, address expected);

    function _doSwap(uint256 amount) external returns (uint256 received) {
        address[] memory path = new address[](2);
        path[0] = address(TEST);
        path[1] = address(WETH);

        uint24[] memory poolFees = new uint24[](1);
        poolFees[0] = 0; // 0.0%

        bytes memory swapData = abi.encode(path, poolFees, amount, 0);
        received = swapWithUniV3(swapData, TEST, WETH);
    }

    function swapWithUniV3(
        bytes memory swapData,
        ERC20 assetIn,
        ERC20 assetOut
    ) public returns (uint256 amountOut) {
        (
            address[] memory path,
            uint24[] memory poolFees,
            uint256 amount,
            uint256 amountOutMin
        ) = abi.decode(swapData, (address[], uint24[], uint256, uint256));

        // Check that path matches assetIn and assetOut.
        if (assetIn != ERC20(path[0]))
            revert SwapRouter__AssetInMisMatch(path[0], address(assetIn));
        if (assetOut != ERC20(path[path.length - 1]))
            revert SwapRouter__AssetOutMisMatch(
                path[path.length - 1],
                address(assetOut)
            );

        // Transfer assets to this contract to swap.
        assetIn.safeTransferFrom(msg.sender, address(this), amount);

        // Approve assets to be swapped through the router.
        assetIn.safeApprove(address(uniswapV3Router), amount);

        // Encode swap parameters.
        bytes memory encodePackedPath = abi.encodePacked(address(assetIn));
        for (uint256 i = 1; i < path.length; i++)
            encodePackedPath = abi.encodePacked(
                encodePackedPath,
                poolFees[i - 1],
                path[i]
            );

        // Execute the swap.
        amountOut = uniswapV3Router.exactInput(
            IUniswapV3Router.ExactInputParams({
                path: encodePackedPath,
                recipient: receiver,
                deadline: block.timestamp + 60,
                amountIn: amount,
                amountOutMinimum: amountOutMin
            })
        );
    }
}
