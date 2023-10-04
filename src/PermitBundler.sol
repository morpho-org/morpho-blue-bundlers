// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.21;

import {IERC20Permit} from "@bundlers/openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Permit.sol";

import {BaseBundler} from "./BaseBundler.sol";

/// @title PermitBundler
/// @author Morpho Labs
/// @custom:contact security@morpho.xyz
/// @notice Bundler contract managing interactions with tokens implementing EIP-2612.
abstract contract PermitBundler is BaseBundler {
    /// @notice Permits the given `amount` of `asset` from sender to be spent by the bundler via EIP-2612 Permit with
    /// the given `deadline` & EIP-712 signature's `v`, `r` & `s`.
    /// @notice Warning: should only be called via the bundler's `multicall` function.
    /// @dev Pass `skipRevert == true` to avoid reverting the whole bundle in case the signature expired.
    function permit(address asset, uint256 amount, uint256 deadline, uint8 v, bytes32 r, bytes32 s, bool skipRevert)
        external
        payable
    {
        try IERC20Permit(asset).permit(initiator, address(this), amount, deadline, v, r, s) {}
        catch (bytes memory returnData) {
            if (!skipRevert) _revert(returnData);
        }
    }
}
