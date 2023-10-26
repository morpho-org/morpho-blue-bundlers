// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.21;

import {IAaveV3Optimizer, Signature} from "./interfaces/IAaveV3Optimizer.sol";

import {Math} from "../../lib/morpho-utils/src/math/Math.sol";
import {ErrorsLib} from "../libraries/ErrorsLib.sol";

import {MigrationBundler, ERC20} from "./MigrationBundler.sol";

/// @title AaveV3OptimizerMigrationBundler
/// @author Morpho Labs
/// @custom:contact security@morpho.org
/// @notice Contract allowing to migrate a position from AaveV3 Optimizer to Morpho Blue easily.
contract AaveV3OptimizerMigrationBundler is MigrationBundler {
    /* IMMUTABLES */

    /// @dev The AaveV3 optimizer contract address.
    IAaveV3Optimizer public immutable AAVE_V3_OPTIMIZER;

    /* CONSTRUCTOR */

    /// @param morpho The Morpho contract Address.
    /// @param aaveV3Optimizer The AaveV3 optimizer contract address. Assumes it is non-zero (not expected to be an
    /// input at deployment).
    constructor(address morpho, address aaveV3Optimizer) MigrationBundler(morpho) {
        AAVE_V3_OPTIMIZER = IAaveV3Optimizer(aaveV3Optimizer);
    }

    /* ACTIONS */

    /// @notice Repays `amount` of `underlying` on the AaveV3 Optimizer, on behalf of the initiator.
    /// @notice Warning: should only be called via the bundler's `multicall` function.
    /// @dev Initiator must have previously transferred their assets to the bundler.
    /// @dev Pass `amount = type(uint256).max` to repay all.
    /// @param underlying The address of the underlying asset to repay.
    /// @param amount The amount of `underlying` to repay.
    function aaveV3OptimizerRepay(address underlying, uint256 amount) external payable {
        amount = Math.min(amount, ERC20(underlying).balanceOf(address(this)));

        require(amount != 0, ErrorsLib.ZERO_AMOUNT);

        _approveMaxTo(underlying, address(AAVE_V3_OPTIMIZER));

        AAVE_V3_OPTIMIZER.repay(underlying, amount, initiator());
    }

    /// @notice Withdraws `amount` of `underlying` on the AaveV3 Optimizer, on behalf of the initiator`.
    /// @notice Warning: should only be called via the bundler's `multicall` function.
    /// @dev Initiator must have previously approved the bundler to manage their AaveV3 Optimizer position.
    /// @dev Pass `amount = type(uint256).max` to withdraw all.
    /// @param underlying The address of the underlying asset to withdraw.
    /// @param amount The amount of `underlying` to withdraw.
    /// @param maxIterations The maximum number of iterations allowed during the matching process. If it is less than
    /// `_defaultIterations.withdraw`, the latter will be used. Pass 0 to fallback to the `_defaultIterations.withdraw`.
    function aaveV3OptimizerWithdraw(address underlying, uint256 amount, uint256 maxIterations) external payable {
        AAVE_V3_OPTIMIZER.withdraw(underlying, amount, initiator(), address(this), maxIterations);
    }

    /// @notice Withdraws `amount` of `underlying` used as collateral on the AaveV3 Optimizer, on behalf of the
    /// initiator.
    /// @notice Warning: should only be called via the bundler's `multicall` function.
    /// @dev Initiator must have previously approved the bundler to manage their AaveV3 Optimizer position.
    /// @dev Pass `amount = type(uint256).max` to withdraw all.
    /// @param underlying The address of the underlying asset to withdraw.
    /// @param amount The amount of `underlying` to withdraw.
    function aaveV3OptimizerWithdrawCollateral(address underlying, uint256 amount) external payable {
        AAVE_V3_OPTIMIZER.withdrawCollateral(underlying, amount, initiator(), address(this));
    }

    /// @notice Approves the bundler to act on behalf of the initiator on the AaveV3 Optimizer, given a signed EIP-712
    /// approval message.
    /// @notice Warning: should only be called via the bundler's `multicall` function.
    /// @param isApproved Whether the bundler is allowed to manage the initiator's position or not.
    /// @param nonce The nonce of the signed message.
    /// @param deadline The deadline of the signed message.
    /// @param signature The signature of the message.
    function aaveV3OptimizerApproveManagerWithSig(
        bool isApproved,
        uint256 nonce,
        uint256 deadline,
        Signature calldata signature
    ) external payable {
        AAVE_V3_OPTIMIZER.approveManagerWithSig(initiator(), address(this), isApproved, nonce, deadline, signature);
    }
}
