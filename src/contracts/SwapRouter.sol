// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IUniswapV3Router} from "./interfaces/external/IUniswapV3Router.sol";

/**
 * @title Sommelier Swap Router
 * @notice Provides a universal interface allowing Sommelier contracts to interact with multiple
 *         different exchanges to perform swaps.
 * @dev Perform multiple swaps using Multicall.
 * @author crispymangoes, Brian Le
 */
contract SwapRouter {
    using SafeERC20 for ERC20;

    /**
     * @notice Uniswap V3 swap router contract.
     */
    IUniswapV3Router public immutable uniswapV3Router; // 0xE592427A0AEce92De3Edee1F18E0157C05861564

    // ========================================== CONSTRUCTOR ==========================================

    constructor(IUniswapV3Router _uniswapV3Router) {
        uniswapV3Router = _uniswapV3Router;
    }

    // ======================================= SWAP OPERATIONS =======================================

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

    /**
     * @notice Perform a swap using a supported exchange.
     * @param swapData encoded data used for the swap
     * @param receiver address to send the received assets to
     * @return amountOut amount of assets received from the swap
     */
    function swap(
        bytes memory swapData,
        address receiver,
        ERC20 assetIn,
        ERC20 assetOut
    ) external returns (uint256 amountOut) {
        // Route swap call to appropriate function using selector.
        (bool success, bytes memory result) = address(this).delegatecall(
            abi.encodeWithSelector(
                SwapRouter(this).swapWithUniV3.selector,
                swapData,
                receiver,
                assetIn,
                assetOut
            )
        );

        if (!success) {
            // If there is return data, the call reverted with a reason or a custom error so we
            // bubble up the error message.
            if (result.length > 0) {
                assembly {
                    let returndata_size := mload(result)
                    revert(add(32, result), returndata_size)
                }
            } else {
                revert SwapRouter__SwapReverted();
            }
        }

        amountOut = abi.decode(result, (uint256));
    }

    /**
     * @notice Perform a swap using Uniswap V3.
     * @param swapData bytes variable storing the following swap information
     *      address[] path: array of addresses dictating what swap path to follow
     *      uint24[] poolFees: array of pool fees dictating what swap pools to use
     *      uint256 amount: amount of the first asset in the path to swap
     *      uint256 amountOutMin: the minimum amount of the last asset in the path to receive
     * @param receiver address to send the received assets to
     * @return amountOut amount of assets received from the swap
     */
    function swapWithUniV3(
        bytes memory swapData,
        address receiver,
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