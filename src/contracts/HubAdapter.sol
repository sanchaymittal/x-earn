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

    constructor(IConnext _connext, address _cellar) {
        connext = _connext;
        cellar = _cellar;
    }

    /**
     * @notice Cross-domain strategy execution at target adaptor.
     * @dev Initiates the Connext bridging flow with calldata to be used at the target adaptor.
     * @param destinationDomain - The unique identifier of destination domain
     * @param asset - The address of Asset
     * @param amount - Amount of the asset
     * @param target - The address of the TargetAdapter at destination domain
     * @param callData - calldata of the target function at destination domain
     */

    function xCallTargetAdapter(
        uint32 destinationDomain,
        address asset,
        uint256 amount,
        address target,
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

        connext.xcall(destinationDomain, target, asset, address(0), amount, 0, callData);
    }

    /** @notice Updates a greeting variable on the HelloTarget contract.
     * @param target Address of the HelloTarget contract.
     * @param destinationDomain The destination domain ID.
     * @param newGreeting New greeting to update to.
     * @param relayerFee The fee offered to relayers. On testnet, this can be 0.
     */
    function updateGreeting(
        address target,
        uint32 destinationDomain,
        string memory newGreeting,
        uint256 relayerFee
    ) external payable {
        // Encode the data needed for the target contract call.
        bytes memory callData = abi.encode(newGreeting);
        connext.xcall{value: relayerFee}(
            destinationDomain, // _destination: Domain ID of the destination chain
            target, // _to: address of the target contract
            address(0), // _asset: address of the token contract
            msg.sender, // _delegate: address that can revert or forceLocal on destination
            0, // _amount: amount of tokens to transfer
            30, // _slippage: the max slippage the user will accept in BPS (0.3%)
            callData // _callData: the encoded calldata to send
        );
    }
}
