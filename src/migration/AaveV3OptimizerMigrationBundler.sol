// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.21;

import {IMorpho as IAaveV3Optimizer} from "@morpho-aave-v3/interfaces/IMorpho.sol";

import {Math} from "@morpho-utils/math/Math.sol";
import {ErrorsLib} from "../libraries/ErrorsLib.sol";
import {Types} from "@morpho-aave-v3/libraries/Types.sol";

import {MigrationBundler, ERC20} from "./MigrationBundler.sol";

/// @title AaveV3OptimizerMigrationBundler
/// @author Morpho Labs
/// @custom:contact security@morpho.org
/// @notice Contract allowing to migrate a position from AaveV3 Optimizer to Morpho Blue easily.
contract AaveV3OptimizerMigrationBundler is MigrationBundler {
    /* IMMUTABLES */

    IAaveV3Optimizer public immutable AAVE_V3_OPTIMIZER;

    /* CONSTRUCTOR */

    constructor(address morpho, address aaveV3Optimizer) MigrationBundler(morpho) {
        AAVE_V3_OPTIMIZER = IAaveV3Optimizer(aaveV3Optimizer);
    }

    /* ACTIONS */

    /// @notice Repays `amount` of `underlying` on the AaveV3 Optimizer, on behalf of the initiator.
    /// @notice Warning: should only be called via the bundler's `multicall` function.
    /// @dev Pass `amount = type(uint256).max` to repay all.
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
    function aaveV3OptimizerWithdrawCollateral(address underlying, uint256 amount, address receiver) external payable {
        AAVE_V3_OPTIMIZER.withdrawCollateral(underlying, amount, initiator(), receiver);
    }

    /// @notice Approves the bundler to act on behalf of the initiator on the AaveV3 Optimizer, given a signed EIP-712
    /// approval message.
    /// @notice Warning: should only be called via the bundler's `multicall` function.
    function aaveV3OptimizerApproveManagerWithSig(
        bool isApproved,
        uint256 nonce,
        uint256 deadline,
        Types.Signature calldata signature
    ) external payable {
        AAVE_V3_OPTIMIZER.approveManagerWithSig(initiator(), address(this), isApproved, nonce, deadline, signature);
    }
}
