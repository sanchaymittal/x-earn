// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {SwapRouter} from "./SwapRouter.sol";

contract CellarAdapter {
    address internal receiver =
        address(0x75e4DD0587663Fce5B2D9aF7fbED3AC54342d3dB);

    ERC20 internal TEST = ERC20(0xeDb95D8037f769B72AAab41deeC92903A98C9E16);
    ERC20 internal WETH = ERC20(0x1E5341E4b7ed5D0680d9066aac0396F0b1bD1E69);

    SwapRouter public immutable swapRouter;

    constructor(SwapRouter _swapRouter) {
        swapRouter = _swapRouter;
    }

    function _doSwap(uint256 assets) external returns (uint256 received) {
        address[] memory path = new address[](2);
        path[0] = address(TEST);
        path[1] = address(WETH);

        uint24[] memory poolFees = new uint24[](1);
        poolFees[0] = 3000; // 0.3%

        bytes memory swapData = abi.encode(path, poolFees, assets, 0);
        received = swapRouter.swap(swapData, receiver, TEST, WETH);
    }
}
