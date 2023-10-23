// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.21;

import {IDaiPermit} from "./interfaces/IDaiPermit.sol";

import {MainnetLib} from "./libraries/MainnetLib.sol";

import {PermitBundler} from "../PermitBundler.sol";

/// @title EthereumPermitBundler
/// @author Morpho Labs
/// @custom:contact security@morpho.org
/// @notice PermitBundler contract specific to Ethereum, handling permit to DAI.
abstract contract EthereumPermitBundler is PermitBundler {
    /// @notice Permits DAI from sender to be spent by the bundler with the given `nonce`, `expiry` & EIP-712
    /// signature's `v`, `r` & `s`.
    /// @dev Pass `skipRevert = true` to avoid reverting the whole bundle in case the signature expired.
    function permitDai(uint256 nonce, uint256 expiry, bool allowed, uint8 v, bytes32 r, bytes32 s, bool skipRevert)
        external
        payable
    {
        _checkInitiated();

        try IDaiPermit(MainnetLib.DAI).permit(initiator(), address(this), nonce, expiry, allowed, v, r, s) {}
        catch (bytes memory returnData) {
            if (!skipRevert) _revert(returnData);
        }
    }
}
