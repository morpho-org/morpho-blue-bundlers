// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.24;

import {IERC20Permit} from "../lib/openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Permit.sol";

import {BaseBundler} from "./BaseBundler.sol";

/// @title PermitBundler
/// @author Morpho Labs
/// @custom:contact security@morpho.org
/// @notice Bundler contract managing interactions with tokens implementing EIP-2612.
abstract contract PermitBundler is BaseBundler {
    /// @notice Permits the given `amount` of `asset` from sender to be spent by the bundler via EIP-2612 Permit with
    /// the given `deadline` & EIP-712 signature's `v`, `r` & `s`.
    /// @param asset The address of the token to be permitted.
    /// @param amount The amount of `asset` to be permitted.
    /// @param deadline The deadline of the approval.
    /// @param v The `v` component of a signature.
    /// @param r The `r` component of a signature.
    /// @param s The `s` component of a signature.
    /// @param skipRevert Whether to avoid reverting the call in case the signature is frontrunned.
    function permit(address asset, uint256 amount, uint256 deadline, uint8 v, bytes32 r, bytes32 s, bool skipRevert)
        external
        payable
        protected
    {
        try IERC20Permit(asset).permit(initiator(), address(this), amount, deadline, v, r, s) {}
        catch (bytes memory returnData) {
            if (!skipRevert) _revert(returnData);
        }
    }
}
