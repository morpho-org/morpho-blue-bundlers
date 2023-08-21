// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.21;

import {IBundlerGateway} from "./interfaces/IBundlerGateway.sol";
import {IMulticall} from "./interfaces/IMulticall.sol";

import {ErrorsLib} from "./libraries/ErrorsLib.sol";

import {BaseSelfMulticall} from "../BaseSelfMulticall.sol";

/// @title BaseBundler
/// @author Morpho Labs
/// @custom:contact security@morpho.xyz
/// @notice Enables calling multiple functions in a single call to the same contract (self) as well as calling other Bundler contracts.
/// @dev Every Bundler must inherit from this contract.
abstract contract BaseBundler is BaseSelfMulticall {
    IBundlerGateway internal immutable BUNDLER_GATEWAY;
    address _initiator;

    constructor(address bundlerGateway) {
        BUNDLER_GATEWAY = IBundlerGateway(bundlerGateway);
    }

    /* MODIFIERS */

    modifier onlyGateway() {
        require(msg.sender == address(BUNDLER_GATEWAY), ErrorsLib.NOT_GATEWAY);
        _;
    }

    modifier setInitiator() {
        address initiator = _initiator;
        if (initiator == address(0)) _initiator = BUNDLER_GATEWAY.initiator();
        _;
    }

    /* EXTERNAL */

    /// @notice Executes a series of calls in a single transaction to self.
    function multicall(bytes[] calldata data) external payable onlyGateway setInitiator returns (bytes[] memory) {
        return _multicall(data);
    }

    /// @notice Executes multiple actions on another `bundler` contract passing along the required `data`.
    function callBundler(address bundler, bytes[] calldata data) external {
        require(bundler != address(0), ErrorsLib.ZERO_ADDRESS);
        require(_initiator != address(0), ErrorsLib.UNINITIATED);

        BUNDLER_GATEWAY.callBundler(bundler, block.timestamp, data);
    }
}
