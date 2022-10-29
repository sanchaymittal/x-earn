// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import "forge-std/Script.sol";
import {IConnext} from "nxtp/core/connext/interfaces/IConnext.sol";
import "../src/contracts/Source.sol";

contract DeploySource is Script {
  function run(address _connext, address _delegate) external {
    vm.startBroadcast();

    IConnext connext = IConnext(_connext);
    new Source(connext, _delegate);

    vm.stopBroadcast();
  }
}