// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.21;

import {IPool} from "@aave/v3-core/interfaces/IPool.sol";

import {Math} from "@morpho-utils/math/Math.sol";
import {ErrorsLib} from "../libraries/ErrorsLib.sol";

import {MigrationBundler, ERC20} from "./MigrationBundler.sol";

/// @title AaveV3MigrationBundler
/// @author Morpho Labs
/// @custom:contact security@morpho.org
/// @notice Contract allowing to migrate a position from Aave V3 to Morpho Blue easily.
contract AaveV3MigrationBundler is MigrationBundler {
    /* IMMUTABLES */

    IPool public immutable AAVE_V3_POOL;

    /* CONSTRUCTOR */

    constructor(address morpho, address wNative, address aaveV3Pool) MigrationBundler(morpho, wNative) {
        AAVE_V3_POOL = IPool(aaveV3Pool);
    }

    /* ACTIONS */

    /// @notice Repays `amount` of `asset` on AaveV3, on behalf of the initiator.
    /// @notice Warning: should only be called via the bundler's `multicall` function.
    /// @dev Pass in `type(uint256).max` to repay all.
    function aaveV3Repay(address asset, uint256 amount, uint256 interestRateMode) external payable {
        amount = Math.min(amount, ERC20(asset).balanceOf(address(this)));

        require(amount != 0, ErrorsLib.ZERO_AMOUNT);

        _approveMaxTo(asset, address(AAVE_V3_POOL));

        AAVE_V3_POOL.repay(asset, amount, interestRateMode, _initiator);
    }

    /// @notice Withdraws `amount` of `asset` on AaveV3, on behalf of the initiator, transferring funds to `receiver`.
    /// @dev Initiator must have previously transferred their aTokens to the bundler.
    /// @dev Pass in `type(uint256).max` to withdraw all.
    function aaveV3Withdraw(address asset, uint256 amount, address receiver) external payable {
        AAVE_V3_POOL.withdraw(asset, amount, receiver);
    }
}
