// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.21;

import {IPool} from "@aave/v3-core/interfaces/IPool.sol";
import {IAToken} from "@aave/v3-core/interfaces/IAToken.sol";

import {Permit2Bundler} from "../Permit2Bundler.sol";
import {PermitBundler} from "../PermitBundler.sol";
import {MigrationBundler} from "./MigrationBundler.sol";

/// @title AaveV3MigrationBundler
/// @author Morpho Labs
/// @custom:contact security@morpho.org
/// @notice Contract allowing to migrate a position from Aave V3 to Morpho Blue easily.
contract AaveV3MigrationBundler is PermitBundler, Permit2Bundler, MigrationBundler {
    /* IMMUTABLES */

    IPool public immutable AAVE_V3_POOL;

    /* CONSTRUCTOR */

    constructor(address morpho, address aaveV3Pool) MigrationBundler(morpho) {
        AAVE_V3_POOL = IPool(aaveV3Pool);
    }

    /* ACTIONS */

    /// @notice Repays `amount` of `asset` on AaveV3, on behalf of the initiator.
    /// @notice Warning: should only be called via the bundler's `multicall` function.
    function aaveV3Repay(address asset, uint256 amount, uint256 interestRateMode) external payable {
        _approveMaxTo(asset, address(AAVE_V3_POOL));

        AAVE_V3_POOL.repay(asset, amount, interestRateMode, _initiator);
    }

    /// @notice Withdraws `amount` of `asset` on AaveV3, on behalf of the initiator, transferring funds to `receiver`.
    /// @dev Initiator must have previously transferred their aTokens to the bundler.
    function aaveV3Withdraw(address asset, uint256 amount, address receiver) external payable {
        AAVE_V3_POOL.withdraw(asset, amount, receiver);
    }
}
