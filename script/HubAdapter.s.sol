// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "forge-std/Script.sol";
import {IConnext} from "nxtp/core/connext/interfaces/IConnext.sol";
import {HubAdapter} from "../src/contracts/HubAdapter.sol";

contract DeployHubAdapter is Script {
    function run() external {
        vm.startBroadcast();

        address _connext = address(0x99A784d082476E551E5fc918ce3d849f2b8e89B6);
        IConnext connext = IConnext(_connext);

        new HubAdapter(connext);

        vm.stopBroadcast();
    }
}
