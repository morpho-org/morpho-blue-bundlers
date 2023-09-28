// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.21;

import {IMulticall} from "./interfaces/IMulticall.sol";

import {Math} from "@morpho-utils/math/Math.sol";
import {ErrorsLib} from "./libraries/ErrorsLib.sol";
import {SafeTransferLib, ERC20} from "solmate/src/utils/SafeTransferLib.sol";

/// @title BaseBundler
/// @author Morpho Labs
/// @custom:contact security@morpho.org
/// @notice Enables calling multiple functions in a single call to the same contract (self) as well as calling other
/// Bundler contracts.
/// @dev Every Bundler must inherit from this contract.
/// @dev Every bundler inheriting from this contract must have their external functions payable as they will be
/// delegate called by the `multicall` function (which is payable, and thus might pass a non-null ETH value). It is
/// recommended not to rely on `msg.value` as the same value can be reused for multiple calls.
/// @dev Assumes that any tokens left on the contract can be seized by anyone.
abstract contract BaseBundler is IMulticall {
    using SafeTransferLib for ERC20;

    /* STORAGE */

    /// @dev Keeps track of the bundler's latest batch initiator. Also prevents interacting with the bundler outside of
    /// an initiated execution context.
    address internal _initiator;

    /* MODIFIERS */

    /// @dev Sets the contract's `_initiator` to the caller of the function, and resets it after the function returns.
    modifier lockInitiator() {
        _initiator = msg.sender;

        _;

        delete _initiator;
    }

    /* PUBLIC */

    /// @notice Executes a series of delegate calls to the contract itself.
    /// @dev It also intitiates `_initiator`.
    /// @dev All functions delegatecalled must be `payable` if `msg.value` is non-zero.
    function multicall(bytes[] memory data) external payable lockInitiator {
        _multicall(data);
    }

    /* TRANSFER ACTIONS */

    /// @notice Transfers the minimum between the given `amount` and the bundler's balance of `asset` from the bundler
    /// to `recipient`.
    /// @dev Pass in `type(uint256).max` to transfer all.
    function transfer(address asset, address recipient, uint256 amount) external payable {
        require(recipient != address(0), ErrorsLib.ZERO_ADDRESS);
        require(recipient != address(this), ErrorsLib.BUNDLER_ADDRESS);

        amount = Math.min(amount, ERC20(asset).balanceOf(address(this)));

        require(amount != 0, ErrorsLib.ZERO_AMOUNT);

        ERC20(asset).safeTransfer(recipient, amount);
    }

    /// @notice Transfers the minimum between the given `amount` and the bundler's balance of native asset from the
    /// bundler to `recipient`.
    /// @dev Pass in `type(uint256).max` to transfer all.
    function transferNative(address recipient, uint256 amount) external payable {
        require(recipient != address(0), ErrorsLib.ZERO_ADDRESS);
        require(recipient != address(this), ErrorsLib.BUNDLER_ADDRESS);

        amount = Math.min(amount, address(this).balance);

        require(amount != 0, ErrorsLib.ZERO_AMOUNT);

        SafeTransferLib.safeTransferETH(recipient, amount);
    }

    /// @notice Transfers the given `amount` of `asset` from sender to this contract via ERC20 transferFrom.
    /// @notice Warning: should only be called via the bundler's `multicall` function.
    /// @dev Pass in `type(uint256).max` to transfer all.
    function transferFrom(address asset, uint256 amount) external payable {
        amount = Math.min(amount, ERC20(asset).balanceOf(_initiator));

        require(amount != 0, ErrorsLib.ZERO_AMOUNT);

        ERC20(asset).safeTransferFrom(_initiator, address(this), amount);
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
        require(_initiator != address(0), ErrorsLib.UNINITIATED);
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
