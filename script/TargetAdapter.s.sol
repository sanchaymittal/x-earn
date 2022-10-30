// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import "forge-std/Script.sol";
import {IConnext} from "nxtp/core/connext/interfaces/IConnext.sol";
import "../src/contracts/TargetAdapter.sol";

contract DeployTargetAdapter is Script {
    function run(address _hub) external {
        vm.startBroadcast();

        address _connext = address(0x99A784d082476E551E5fc918ce3d849f2b8e89B6);
        uint32 originDomain = 1735353714; // goerli
        IConnext connext = IConnext(_connext);
        new TargetAdapter(_hub, originDomain, connext);

        vm.stopBroadcast();
    }
}
