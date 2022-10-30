// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "forge-std/Script.sol";
import {IConnext} from "nxtp/core/connext/interfaces/IConnext.sol";
import {HubAdapter} from "../src/contracts/HubAdapter.sol";

contract DeployHubAdapter is Script {
    function run() external {
        vm.startBroadcast();

        address _connext = address(0x13c96809fCF9f6542eb35c69B580dFa05ee9D70b);
        IConnext connext = IConnext(_connext);

        new HubAdapter(connext);

        vm.stopBroadcast();
    }
}
