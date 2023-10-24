// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.21;

import {Math} from "../lib/morpho-utils/src/math/Math.sol";
import {ErrorsLib} from "./libraries/ErrorsLib.sol";
import {SafeTransferLib, ERC20} from "../lib/solmate/src/utils/SafeTransferLib.sol";

import {BaseBundler} from "./BaseBundler.sol";

/// @title TransferBundler
/// @author Morpho Labs
/// @custom:contact security@morpho.org
/// @notice Enables transfer of ERC20 and native tokens.
/// @dev Assumes that any tokens left on the contract can be seized by anyone.
abstract contract TransferBundler is BaseBundler {
    using SafeTransferLib for ERC20;

    /* TRANSFER ACTIONS */

    /// @notice Transfers the minimum between the given `amount` and the bundler's balance of native asset from the
    /// bundler to `recipient`.
    /// @dev Pass `amount = type(uint256).max` to transfer all.
    /// @param recipient The address that will receive the native tokens.
    /// @param amount The amount of native tokens to transfer.
    function nativeTransfer(address recipient, uint256 amount) external payable {
        require(recipient != address(0), ErrorsLib.ZERO_ADDRESS);
        require(recipient != address(this), ErrorsLib.BUNDLER_ADDRESS);

        amount = Math.min(amount, address(this).balance);

        require(amount != 0, ErrorsLib.ZERO_AMOUNT);

        SafeTransferLib.safeTransferETH(recipient, amount);
    }

    /// @notice Transfers the minimum between the given `amount` and the bundler's balance of `asset` from the bundler
    /// to `recipient`.
    /// @dev Pass `amount = type(uint256).max` to transfer all.
    /// @param asset The address of the ERC20 token to transfer.
    /// @param recipient The address that will receive the tokens.
    /// @param amount The amount of `asset` to transfer.
    function erc20Transfer(address asset, address recipient, uint256 amount) external payable {
        require(recipient != address(0), ErrorsLib.ZERO_ADDRESS);
        require(recipient != address(this), ErrorsLib.BUNDLER_ADDRESS);

        amount = Math.min(amount, ERC20(asset).balanceOf(address(this)));

        require(amount != 0, ErrorsLib.ZERO_AMOUNT);

        ERC20(asset).safeTransfer(recipient, amount);
    }

    /// @notice Transfers the given `amount` of `asset` from sender to this contract via ERC20 transferFrom.
    /// @notice Warning: should only be called via the bundler's `multicall` function.
    /// @dev Pass `amount = type(uint256).max` to transfer all.
    /// @param asset The address of the ERC20 token to transfer.
    /// @param amount The amount of `asset` to transfer from the initiator.
    function erc20TransferFrom(address asset, uint256 amount) external payable {
        address initiator = initiator();
        amount = Math.min(amount, ERC20(asset).balanceOf(initiator));

        require(amount != 0, ErrorsLib.ZERO_AMOUNT);

        ERC20(asset).safeTransferFrom(initiator, address(this), amount);
    }
}
