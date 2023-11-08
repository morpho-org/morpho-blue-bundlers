// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.21;

import {IAaveV2} from "./interfaces/IAaveV2.sol";

import {Math} from "../../lib/morpho-utils/src/math/Math.sol";
import {ErrorsLib} from "../libraries/ErrorsLib.sol";

import {MigrationBundler, ERC20} from "./MigrationBundler.sol";

/// @title AaveV2MigrationBundler
/// @author Morpho Labs
/// @custom:contact security@morpho.org
/// @notice Contract allowing to migrate a position from Aave V2 to Morpho Blue easily.
/// If deploying to Ethereum, deploy `AaveV2EthereumMigrationBundler` instead.
contract AaveV2MigrationBundler is MigrationBundler {
    /* IMMUTABLES */

    /// @dev The AaveV2 contract address.
    IAaveV2 public immutable AAVE_V2_POOL;

    /* CONSTRUCTOR */

    /// @param morpho The Morpho contract Address.
    /// @param aaveV2Pool The AaveV2 contract address. Assumes it is non-zero (not expected to be an input at
    /// deployment).
    constructor(address morpho, address aaveV2Pool) MigrationBundler(morpho) {
        AAVE_V2_POOL = IAaveV2(aaveV2Pool);
    }

    /* ACTIONS */

    /// @notice Repays `amount` of `asset` on AaveV2, on behalf of the initiator.
    /// @dev Initiator must have previously transferred their assets to the bundler.
    /// @param asset The address of the token to repay.
    /// @param amount The amount of `asset` to repay. Pass `type(uint256).max` to repay the bundler's `asset` balance.
    /// @param interestRateMode The interest rate mode of the position.
    function aaveV2Repay(address asset, uint256 amount, uint256 interestRateMode) external payable protected {
        if (amount != type(uint256).max) amount = Math.min(amount, ERC20(asset).balanceOf(address(this)));

        require(amount != 0, ErrorsLib.ZERO_AMOUNT);

        _approveMaxTo(asset, address(AAVE_V2_POOL));

        AAVE_V2_POOL.repay(asset, amount, interestRateMode, initiator());
    }

    /// @notice Withdraws `amount` of `asset` on AaveV2, on behalf of the initiator.
    /// @notice Withdrawn assets are received by the bundler and should be used afterwards.
    /// @dev Initiator must have previously transferred their aTokens to the bundler.
    /// @param asset The address of the token to withdraw.
    /// @param amount The amount of `asset` to withdraw. Pass `type(uint256).max` to withdraw all.
    function aaveV2Withdraw(address asset, uint256 amount) external payable protected {
        AAVE_V2_POOL.withdraw(asset, amount, address(this));
    }
}
