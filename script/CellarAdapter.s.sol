// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "forge-std/Script.sol";
import {SwapRouter} from "../src/contracts/SwapRouter.sol";
import {CellarAdapter} from "../src/contracts/CellarAdapter.sol";

contract DeployCellarAdapter is Script {
    function run() external {
        vm.startBroadcast();

        address _swapRouter = address(0xe2611ff69a495464021335347FE4DeBB637746eE);
        SwapRouter swapRouter = SwapRouter(_swapRouter);

        new CellarAdapter(swapRouter);

        vm.stopBroadcast();
    }
}
