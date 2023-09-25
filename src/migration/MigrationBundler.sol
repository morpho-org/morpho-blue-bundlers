// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.21;

import {SafeTransferLib, ERC20} from "solmate/src/utils/SafeTransferLib.sol";

import {ERC4626Bundler} from "../ERC4626Bundler.sol";
import {MorphoBundler} from "../MorphoBundler.sol";

/// @title MigrationBundler
/// @author Morpho Labs
/// @custom:contact security@morpho.org
/// @notice Abstract contract allowing to migrate a position from one lending protocol to Morpho Blue easily.
abstract contract MigrationBundler is ERC4626Bundler, MorphoBundler {
    using SafeTransferLib for ERC20;

    /* CONSTRUCTOR */

    constructor(address morpho) MorphoBundler(morpho) {}

    /* INTERNAL */

    /// @dev Gives the max approval to `to` to spend the given `asset` if not already approved.
    function _approveMaxTo(address asset, address to) internal {
        if (ERC20(asset).allowance(address(this), to) == 0) {
            ERC20(asset).safeApprove(to, type(uint256).max);
        }
    }
}