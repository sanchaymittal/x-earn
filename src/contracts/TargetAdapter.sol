// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import {IConnext} from "nxtp/core/connext/interfaces/IConnext.sol";
// import {IExecutor} from "nxtp/core/connext/interfaces/IExecutor.sol";
// import {LibCrossDomainProperty} from "nxtp/core/connext/libraries/LibConnextStorag.sol";

/**
 * @title Target
 * @notice A contrived example target contract.
 */
contract Target {
  event UpdateCompleted(address sender, uint256 newValue, bool authenticated);

  uint256 public value;

  // The address of Source.sol
  address public originContract;

  // The origin Domain ID
  uint32 public originDomain;

  // The address of the Connext Executor contract
  IConnext public immutable connext;

  // A modifier for authenticated function calls.
  // Note: This is an important security consideration. If your target
  //       contract function is meant to be authenticated, it must check
  //       that the originating call is from the correct domain and contract.
  //       Also, it must be coming from the Connext Executor address.
  modifier onlyExecutor() {
    require(
    //   LibCrossDomainProperty.originSender(msg.data) == originContract &&
    //     LibCrossDomainProperty.origin(msg.data) == originDomain &&
        msg.sender == address(connext),
      "Expected origin contract on origin domain called by Executor"
    );
    _;
  }

  constructor(
    address _originContract,
    uint32 _originDomain,
    IConnext _connext
  ) {
    originContract = _originContract;
    originDomain = _originDomain;
    connext = _connext;
  }

  // Unauthenticated function
  function updateValueUnauthenticated(uint256 newValue) 
    external 
    returns (uint256)
  {
    value = newValue;

    emit UpdateCompleted(msg.sender, newValue, false);
    return newValue;
  }

  // Authenticated function
  function updateValueAuthenticated(uint256 newValue) 
    external onlyExecutor 
    returns (uint256)
  {
    value = newValue;

    emit UpdateCompleted(msg.sender, newValue, true);
    return newValue;
  }
}
