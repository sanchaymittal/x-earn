

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import "forge-std/Script.sol";
import {IConnext} from "nxtp/core/connext/interfaces/IConnext.sol";
import "../src/contracts/TargetAdapter.sol";

contract DeployTarget is Script {
  function run(address _source, uint32 _originDomain, address _connext) external {
    vm.startBroadcast();

    IConnext connext = IConnext(_connext);
    new TargetAdapter(_source, _originDomain, connext);

    vm.stopBroadcast();
  }
}