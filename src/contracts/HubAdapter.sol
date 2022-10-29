

// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.14;

import {IConnext} from "nxtp/core/connext/interfaces/IConnext.sol";

/**
 * @title HubAdapters
 * @notice TODO
 */
contract HubAdapter {
  event UpdateInitiated(address to, uint256 newValue, bool authenticated);

  IConnext public immutable connext;

  address public delegate;


  constructor(IConnext _connext, address _delegate) {
    connext = _connext;
    delegate = _delegate;
  }

  /**
   * Cross-domain update of a value on a target contract.
   @dev Initiates the Connext bridging flow with calldata to be used on the target contract.
   */
  function xChainUpdate(
    uint32 destination,
    address to,
    address asset,
    uint256 amount
  ) external payable {
    // bytes memory callData = abi.encodeWithSelector(selector, );
    bytes memory callData = "0x";


  // function xcall(
  //   uint32 _destination,
  //   address _to,
  //   address _asset,
  //   address _delegate,
  //   uint256 _amount,
  //   uint256 _slippage,
  //   bytes calldata _callData
  // ) external payable returns (bytes32);

    connext.xcall(
      destination,
      to,
      asset,
      delegate,
      amount,
      0,
      callData
    );
  }
}