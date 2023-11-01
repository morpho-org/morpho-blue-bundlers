// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.21;

import {IWNative} from "./interfaces/IWNative.sol";

import {Math} from "../lib/morpho-utils/src/math/Math.sol";
import {ErrorsLib} from "./libraries/ErrorsLib.sol";
import {SafeTransferLib, ERC20} from "../lib/solmate/src/utils/SafeTransferLib.sol";

import {BaseBundler} from "./BaseBundler.sol";

/// @title WNativeBundler
/// @author Morpho Labs
/// @custom:contact security@morpho.org
/// @notice Bundler contract managing interactions with network's wrapped native token.
/// @notice "wrapped native" refers to forks of WETH.
abstract contract WNativeBundler is BaseBundler {
    using SafeTransferLib for ERC20;

    /* IMMUTABLES */

    /// @dev The address of the wrapped native token contract.
    address public immutable WRAPPED_NATIVE;

    /* CONSTRUCTOR */

    /// @dev Warning: assumes the given addresses are non-zero (they are not expected to be deployment arguments).
    /// @param wNative The address of the wNative token contract.
    constructor(address wNative) {
        require(wNative != address(0), ErrorsLib.ZERO_ADDRESS);

        WRAPPED_NATIVE = wNative;
    }

    /* FALLBACKS */

    /// @dev Allows the wrapped native contract to send native tokens to the bundler.
    receive() external payable {}

    /* ACTIONS */

    /// @notice Wraps the given `amount` of the native token to wNative.
    /// @dev Pass `amount = type(uint256).max` to wrap all.
    /// @param amount The amount of native token to wrap.
    function wrapNative(uint256 amount) external payable onlyInitiated {
        amount = Math.min(amount, address(this).balance);

        require(amount != 0, ErrorsLib.ZERO_AMOUNT);

        IWNative(WRAPPED_NATIVE).deposit{value: amount}();
    }

    /// @notice Unwraps the given `amount` of wNative to the native token.
    /// @dev Pass `amount = type(uint256).max` to unwrap all.
    /// @param amount The amount of wrapped native token to unwrap.
    function unwrapNative(uint256 amount) external payable onlyInitiated {
        amount = Math.min(amount, ERC20(WRAPPED_NATIVE).balanceOf(address(this)));

        require(amount != 0, ErrorsLib.ZERO_AMOUNT);

        IWNative(WRAPPED_NATIVE).withdraw(amount);
    }
}
