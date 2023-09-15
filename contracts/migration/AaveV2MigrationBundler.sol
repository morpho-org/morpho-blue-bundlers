// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.21;

import {ILendingPool} from "@morpho-v1/aave-v2/interfaces/aave/ILendingPool.sol";

import {Permit2Bundler} from "../Permit2Bundler.sol";
import {MigrationBundler} from "./MigrationBundler.sol";

/// @title AaveV2MigrationBundler
/// @author Morpho Labs
/// @custom:contact security@morpho.org
/// @notice Contract allowing to migrate a position from Aave V2 to Morpho Blue easily.
contract AaveV2MigrationBundler is MigrationBundler, Permit2Bundler {
    /* IMMUTABLES */

    ILendingPool public immutable AAVE_V2_POOl;

    /* CONSTRUCTOR */

    constructor(address morpho, address aaveV2Pool) MigrationBundler(morpho) {
        AAVE_V2_POOl = ILendingPool(aaveV2Pool);
    }

    /* ACTIONS */

    /// @notice Repays `amount` of `asset` on AaveV2, on behalf of the initiator.
    /// @notice Warning: should only be called via the bundler's `multicall` function.
    function aaveV2Repay(address asset, uint256 amount, uint256 interestRateMode) external payable {
        _approveMaxTo(asset, address(AAVE_V2_POOl));

        AAVE_V2_POOl.repay(asset, amount, interestRateMode, _initiator);
    }

    /// @notice Withdraws `amount` of `asset` on AaveV3, on behalf of the initiator, transferring funds to `receiver`.
    /// @dev Initiator must have previously transferred their aTokens to the bundler.
    function aaveV2Withdraw(address asset, uint256 amount, address receiver) external payable {
        AAVE_V2_POOl.withdraw(asset, amount, receiver);
    }
}
