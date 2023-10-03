// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.21;

import {IMulticall} from "./interfaces/IMulticall.sol";

import {ErrorsLib} from "./libraries/ErrorsLib.sol";

/// @title BaseBundler
/// @author Morpho Labs
/// @custom:contact security@morpho.org
/// @notice Enables calling multiple functions in a single call to the same contract (self).
/// @dev Every Bundler must inherit from this contract.
/// @dev Every bundler inheriting from this contract must have their external functions payable as they will be
/// delegate called by the `multicall` function (which is payable, and thus might pass a non-null ETH value). It is
/// recommended not to rely on `msg.value` as the same value can be reused for multiple calls.
abstract contract BaseBundler is IMulticall {
    /* STORAGE */

    /// @notice Keeps track of the bundler's latest bundle initiator.
    /// @dev Also prevents interacting with the bundler outside of an initiated execution context.
    address public initiator;

    /* EXTERNAL */

    /// @notice Executes a series of delegate calls to the contract itself.
    /// @dev Locks the initiator so that the sender can uniquely be identified in callbacks.
    /// @dev All functions delegatecalled must be `payable` if `msg.value` is non-zero.
    function multicall(bytes[] memory data) external payable {
        initiator = msg.sender;

        _multicall(data);

        delete initiator;
    }

    /* INTERNAL */

    /// @dev Executes a series of delegate calls to the contract itself.
    /// @dev All functions delegatecalled must be `payable` if `msg.value` is non-zero.
    function _multicall(bytes[] memory data) internal {
        for (uint256 i; i < data.length; ++i) {
            (bool success, bytes memory returnData) = address(this).delegatecall(data[i]);

            // No need to check that `address(this)` has code in case of success.
            if (!success) _revert(returnData);
        }
    }

    /// @dev Checks that the contract is in an initiated execution context.
    function _checkInitiated() internal view {
        require(initiator != address(0), ErrorsLib.UNINITIATED);
    }

    /// @dev Bubbles up the revert reason / custom error encoded in `returnData`.
    /// @dev Assumes `returnData` is the return data of any kind of failing CALL to a contract.
    function _revert(bytes memory returnData) internal pure {
        uint256 length = returnData.length;
        require(length > 0, ErrorsLib.CALL_FAILED);

        assembly ("memory-safe") {
            revert(add(32, returnData), length)
        }
    }
}
