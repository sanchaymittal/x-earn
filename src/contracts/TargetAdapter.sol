// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import {IConnext} from "nxtp/core/connext/interfaces/IConnext.sol";
import {IXReceiver} from "@connext/nxtp-contracts/contracts/core/connext/interfaces/IXReceiver.sol";
import {TypedMemView} from "nxtp/shared/libraries/TypedMemView.sol";

/**
 * @title Target
 * @notice A contrived example target contract.
 */
contract TargetAdapter is IXReceiver {
    // ============ Libraries ============
    using TypedMemView for bytes;
    using TypedMemView for bytes29;

    // ============ Constants ============

    // 32 bytes amount + 4 bytes domain + 20 bytes address = 56 bytes;
    uint256 private constant PROPERTIES_LENGTH = 56;

    uint256 public value;

    // The address of Source.sol
    address public originContract;

    // The origin Domain ID
    uint32 public originDomain;

    // The address of the Connext Executor contract
    IConnext public immutable connext;

    event XReceive(
        bytes32 _transferId,
        uint256 _amount,
        address _asset,
        address _originSender,
        uint32 _origin,
        bytes _callData
    );

    error TargetAdapter__onlyExecutor_notExecutor();
    error TargetAdapter__onlyOriginSender_notOriginSender();

    modifier onlyOriginSender(address _originSender) {
        if (_originSender != originContract)
            revert TargetAdapter__onlyOriginSender_notOriginSender();
        _;
    }

    // A modifier for authenticated function calls.
    // Note: This is an important security consideration. If your target
    //       contract function is meant to be authenticated, it must check
    //       that the originating call is from the correct domain and contract.
    //       Also, it must be coming from the Connext Executor address.
    modifier onlyExecutor(uint32 _origin) {
        if (msg.sender != address(connext) && _origin != originDomain)
            revert TargetAdapter__onlyExecutor_notExecutor();
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

    // example implementation
    function xReceive(
        bytes32 _transferId,
        uint256 _amount,
        address _asset,
        address _originSender,
        uint32 _origin,
        bytes memory _callData
    ) external returns (bytes memory) {
        // Unpack the _callData
        string memory newGreeting = abi.decode(_callData, (string));
        _updateGreeting(newGreeting);

        emit XReceive(
            _transferId,
            _amount,
            _asset,
            _originSender,
            _origin,
            _callData
        );
    }

    function _withdrawToOrigin(address _asset, uint256 _amount) internal {
        connext.xcall(
            originDomain,
            originContract,
            _asset,
            address(0),
            _amount,
            0,
            ""
        );
    }

    // ============ INTERNAL ============

    /** @notice Internal function to update the greeting.
     * @param _newGreeting Calldata containing the new greeting.
     */
    function _updateGreeting(string memory _newGreeting) internal pure {
        string memory newGreeting = _newGreeting;
    }

    /**
     * @notice Parses the origin domain from the msg.data
     * @dev See warning at the top of the file about usage
     * @param _data The msg.data sent by executor
     * @return uint32 origin domain
     */
    function origin(bytes memory _data) internal pure returns (uint32) {
        // create view
        bytes29 typed = _data.ref(0);
        // before the domain = calldata + amount
        return uint32(typed.indexUint(callDataLength(typed) + 32, 4));
    }

    /**
     * @notice Parses the origin msg.sender from the msg.data
     * @dev See warning at the top of the file about usage
     * @param _data The msg.data sent by executor
     * @return address The msg.sender of the initial `xcall`
     */
    function originSender(bytes memory _data) internal pure returns (address) {
        // create view
        bytes29 typed = _data.ref(0);
        // before the domain = calldata + amount + domain
        return typed.indexAddress(callDataLength(typed) + 36);
    }

    /**
     * @notice Used internally to get the length of the calldata included
     * @dev See warning at the top of the file about usage
     * @param _view The msg.data sent by executor cast as a TypedMemView
     * @return uint256 Length of the calldata
     */
    function callDataLength(bytes29 _view) internal pure returns (uint256) {
        uint256 len = _view.len();
        require(len >= PROPERTIES_LENGTH, "!length");
        // The data will be packed with the properties appended to the data
        return len - PROPERTIES_LENGTH;
    }
}
