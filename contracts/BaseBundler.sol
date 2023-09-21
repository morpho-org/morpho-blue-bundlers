// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.21;

import {ErrorsLib} from "./libraries/ErrorsLib.sol";
import {Math} from "@morpho-utils/math/Math.sol";
import {SafeTransferLib, ERC20} from "solmate/src/utils/SafeTransferLib.sol";

import {Multidelegatecall, Call} from "./Multidelegatecall.sol";
import {BaseCallbackReceiver} from "./BaseCallbackReceiver.sol";

/// @title BaseBundler
/// @author Morpho Labs
/// @custom:contact security@morpho.org
/// @notice Enables calling multiple functions in a single call to the same contract (self) as well as calling other
/// Bundler contracts.
/// @dev Every Bundler must inherit from this contract.
/// @dev Every bundler inheriting from this contract must have their external functions payable as they will be
/// delegate called by the `multicall` function (which is payable, and thus might pass a non-null ETH value).
abstract contract BaseBundler is Multidelegatecall, BaseCallbackReceiver {
    using SafeTransferLib for ERC20;

    /* PUBLIC */

    /// @notice Executes a series of calls in a single transaction to self.
    function multicall(uint256 deadline, Call[] calldata data)
        public
        payable
        override
        lockInitiator
        returns (bytes[] memory)
    {
        return super.multicall(deadline, data);
    }

    /* EXTERNAL */

    /// @notice Transfers the minimum between the given `amount` and the bundler's balance of `asset` from the bundler
    /// to `recipient`.
    function transfer(address asset, address recipient, uint256 amount) external payable {
        require(recipient != address(0), ErrorsLib.ZERO_ADDRESS);
        require(recipient != address(this), ErrorsLib.BUNDLER_ADDRESS);

        amount = Math.min(amount, ERC20(asset).balanceOf(address(this)));

        require(amount != 0, ErrorsLib.ZERO_AMOUNT);

        ERC20(asset).safeTransfer(recipient, amount);
    }

    /// @notice Transfers the minimum between the given `amount` and the bundler's balance of native asset from the
    /// bundler to `recipient`.
    function transferNative(address recipient, uint256 amount) external payable {
        require(recipient != address(0), ErrorsLib.ZERO_ADDRESS);
        require(recipient != address(this), ErrorsLib.BUNDLER_ADDRESS);

        amount = Math.min(amount, address(this).balance);

        require(amount != 0, ErrorsLib.ZERO_AMOUNT);

        SafeTransferLib.safeTransferETH(recipient, amount);
    }
}
