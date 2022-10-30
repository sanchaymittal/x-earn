// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "forge-std/Script.sol";
import {CellarAdapter} from "../src/contracts/CellarAdapter.sol";

contract DeployCellarAdapter is Script {
    function run() external {
        vm.startBroadcast();

        new CellarAdapter();

        vm.stopBroadcast();
    }
}
