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

    IAaveV2 public immutable AAVE_V2_POOL;

    /* CONSTRUCTOR */

    constructor(address morpho, address aaveV2Pool) MigrationBundler(morpho) {
        AAVE_V2_POOL = IAaveV2(aaveV2Pool);
    }

    /* ACTIONS */

    /// @notice Repays `amount` of `asset` on AaveV2, on behalf of the initiator.
    /// @notice Warning: should only be called via the bundler's `multicall` function.
    /// @dev Pass `amount = type(uint256).max` to repay all.
    function aaveV2Repay(address asset, uint256 amount, uint256 interestRateMode) external payable {
        amount = Math.min(amount, ERC20(asset).balanceOf(address(this)));

        require(amount != 0, ErrorsLib.ZERO_AMOUNT);

        _approveMaxTo(asset, address(AAVE_V2_POOL));

        AAVE_V2_POOL.repay(asset, amount, interestRateMode, initiator());
    }

    /// @notice Withdraws `amount` of `asset` on AaveV2, on behalf of the initiator, transferring funds to `receiver`.
    /// @dev Initiator must have previously transferred their aTokens to the bundler.
    /// @dev Pass `amount = type(uint256).max` to withdraw all.
    function aaveV2Withdraw(address asset, uint256 amount, address receiver) external payable {
        require(receiver != address(0), ErrorsLib.ZERO_ADDRESS);

        AAVE_V2_POOL.withdraw(asset, amount, receiver);
    }
}
