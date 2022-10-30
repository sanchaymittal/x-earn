// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "forge-std/Script.sol";
import {IUniswapV3Router} from "../src/contracts/interfaces/external/IUniswapV3Router.sol";
import {SwapRouter} from "../src/contracts/SwapRouter.sol";

contract DeploySwapRouter is Script {
    function run() external {
        vm.startBroadcast();

        address _uniswapV3Router = address(0xE592427A0AEce92De3Edee1F18E0157C05861564);
        IUniswapV3Router uniswapV3Router = IUniswapV3Router(_uniswapV3Router);

        new SwapRouter(uniswapV3Router);

        vm.stopBroadcast();
    }
}
