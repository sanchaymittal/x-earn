// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

import {IConnext} from "nxtp/core/connext/interfaces/IConnext.sol";

/**
 * @title HubAdapters
 * @notice TODO
 */
contract HubAdapter {
    IConnext public immutable connext;

    address public immutable cellar;

    error HubAdapter__onlyCellar_notCellar();

    // A modifier for authenticated function calls.
    // Note: This is an important security consideration. If your target
    //       contract function is meant to be authenticated, it must check
    //       that the originating call is from the correct domain and contract.
    //       Also, it must be coming from the Connext Executor address.
    modifier onlyCeller() {
        if (msg.sender != address(cellar))
            revert HubAdapter__onlyCellar_notCellar();
        _;
    }
    event UpdateInitiated(address to, uint256 newValue, bool authenticated);

    constructor(IConnext _connext, address _cellar) {
        connext = _connext;
        cellar = _cellar;
    }

    /**
   * Cross-domain update of a value on a target contract.
   @dev Initiates the Connext bridging flow with calldata to be used on the target contract.
   */
    function xCallTargetAdapter(
        uint32 destination,
        address asset,
        uint256 amount,
        address to,
        bytes memory callData
    ) external payable onlyCeller {
        // function xcall(
        //   uint32 _destination,
        //   address _to,
        //   address _asset,
        //   address _delegate,
        //   uint256 _amount,
        //   uint256 _slippage,
        //   bytes calldata _callData
        // ) external payable returns (bytes32);

        connext.xcall(destination, to, asset, address(0), amount, 0, callData);
    }
}
