// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.21;

import {Signature} from "@morpho-blue/interfaces/IMorpho.sol";

import {ErrorsLib} from "./libraries/ErrorsLib.sol";
import {ERC20, Permit2Lib} from "@permit2/libraries/Permit2Lib.sol";
import {SafeCast160} from "@permit2/libraries/SafeCast160.sol";

import {BaseBundler} from "./BaseBundler.sol";

/// @title Permit2Bundler
/// @author Morpho Labs
/// @custom:contact security@morpho.xyz
/// @notice Bundler contract managing interactions with ERC20 compliant tokens.
/// @dev It leverages Uniswap's Permit2 contract.
abstract contract Permit2Bundler is BaseBundler {
    using SafeCast160 for uint256;
    using Permit2Lib for ERC20;

    /* ACTIONS */

    /// @notice Approves the given `amount` of `asset` from sender to be spent by this contract via Permit2 with the
    /// given `deadline` & EIP-712 `signature`.
    /// @notice Warning: should only be called via the bundler's `multicall` function.
    function approve2(address asset, uint256 amount, uint256 deadline, Signature calldata signature) external payable {
        require(amount != 0, ErrorsLib.ZERO_AMOUNT);

        ERC20(asset).simplePermit2(_initiator, address(this), amount, deadline, signature.v, signature.r, signature.s);
    }

    /// @notice Transfers the given `amount` of `asset` from sender to this contract via ERC20 transfer with Permit2.
    /// @notice Warning: should only be called via the bundler's `multicall` function.
    function transferFrom2(address asset, uint256 amount) external payable {
        require(amount != 0, ErrorsLib.ZERO_AMOUNT);

        Permit2Lib.PERMIT2.transferFrom(_initiator, address(this), amount.toUint160(), asset);
    }
}
