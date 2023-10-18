// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.21;

import {IMorpho as IAaveV3Optimizer} from "../../lib/morpho-aave-v3/src/interfaces/IMorpho.sol";

import {Math} from "../../lib/morpho-utils/src/math/Math.sol";
import {ErrorsLib} from "../libraries/ErrorsLib.sol";
import {Types} from "../../lib/morpho-aave-v3/src/libraries/Types.sol";

import {MigrationBundler, ERC20} from "./MigrationBundler.sol";

/// @title AaveV3OptimizerMigrationBundler
/// @author Morpho Labs
/// @custom:contact security@morpho.org
/// @notice Contract allowing to migrate a position from AaveV3 Optimizer to Morpho Blue easily.
contract AaveV3OptimizerMigrationBundler is MigrationBundler {
    /* IMMUTABLES */

    /// @dev The AaveV3 optmizer contract address.
    IAaveV3Optimizer public immutable AAVE_V3_OPTIMIZER;

    /* CONSTRUCTOR */

    /// @dev Warning: assumes the aaveV3Optimizer address is non-zero (not expected to be deployment arguments).
    /// @param morpho The Morpho contract Address.
    /// @param aaveV3Optimizer The AaveV3 optmizer contract address.
    constructor(address morpho, address aaveV3Optimizer) MigrationBundler(morpho) {
        AAVE_V3_OPTIMIZER = IAaveV3Optimizer(aaveV3Optimizer);
    }

    /* ACTIONS */

    /// @notice Repays `amount` of `underlying` on the AaveV3 Optimizer, on behalf of the initiator.
    /// @notice Warning: should only be called via the bundler's `multicall` function.
    /// @dev Pass `amount = type(uint256).max` to repay all.
    /// @param underlying The address of the underlying asset to repay.
    /// @param amount The amount of `underlying` to repay.
    function aaveV3OptimizerRepay(address underlying, uint256 amount) external payable {
        amount = Math.min(amount, ERC20(underlying).balanceOf(address(this)));

        require(amount != 0, ErrorsLib.ZERO_AMOUNT);

        _approveMaxTo(underlying, address(AAVE_V3_OPTIMIZER));

        AAVE_V3_OPTIMIZER.repay(underlying, amount, initiator());
    }

    /// @notice Repays `amount` of `underlying` on the AaveV3 Optimizer, on behalf of the initiator, transferring funds
    /// to `receiver`.
    /// @notice Warning: should only be called via the bundler's `multicall` function.
    /// @dev Initiator must have previously approved the bundler to manage their AaveV3 Optimizer position.
    /// @dev Pass `amount = type(uint256).max` to withdraw all.
    /// @param underlying The address of the underlying asset to withdraw.
    /// @param amount The amount of `underlying` to withdraw.
    /// @param receiver The address that will receive the withdrawn funds.
    /// @param maxIterations The maximum number of iterations allowed during the matching process. If it is less than
    /// `_defaultIterations.withdraw`, the latter will be used. Pass 0 to fallback to the `_defaultIterations.withdraw`.
    function aaveV3OptimizerWithdraw(address underlying, uint256 amount, address receiver, uint256 maxIterations)
        external
        payable
    {
        AAVE_V3_OPTIMIZER.withdraw(underlying, amount, initiator(), receiver, maxIterations);
    }

    /// @notice Repays `amount` of `underlying` on the AaveV3 Optimizer, on behalf of the initiator, transferring funds
    /// to `receiver`.
    /// @notice Warning: should only be called via the bundler's `multicall` function.
    /// @dev Initiator must have previously approved the bundler to manage their AaveV3 Optimizer position.
    /// @dev Pass `amount = type(uint256).max` to withdraw all.
    /// @param underlying The address of the underlying asset to withdraw.
    /// @param amount The amount of `underlying` to withdraw.
    /// @param receiver The address that will receive the withdrawn funds.
    function aaveV3OptimizerWithdrawCollateral(address underlying, uint256 amount, address receiver) external payable {
        AAVE_V3_OPTIMIZER.withdrawCollateral(underlying, amount, initiator(), receiver);
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
        Types.Signature calldata signature
    ) external payable {
        AAVE_V3_OPTIMIZER.approveManagerWithSig(initiator(), address(this), isApproved, nonce, deadline, signature);
    }
}
