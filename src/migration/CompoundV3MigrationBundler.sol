// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.21;

import {ICompoundV3} from "./interfaces/ICompoundV3.sol";

import {ErrorsLib} from "../libraries/ErrorsLib.sol";
import {Math} from "@morpho-utils/math/Math.sol";

import {MigrationBundler, ERC20} from "./MigrationBundler.sol";

/// @title CompoundV3MigrationBundler
/// @author Morpho Labs
/// @custom:contact security@morpho.org
/// @notice Contract allowing to migrate a position from Compound V3 to Morpho Blue easily.
contract CompoundV3MigrationBundler is MigrationBundler {
    /* CONSTRUCTOR */

    constructor(address morpho) MigrationBundler(morpho) {}

    /* ACTIONS */

    /// @notice Repays `amount` of `asset` on the CompoundV3 `instance`, on behalf of the initiator.
    /// @notice Warning: should only be called via the bundler's `multicall` function.
    /// @dev Assumes the given instance is a CompoundV3 instance.
    /// @dev Pass in `type(uint256).max` to repay all.
    function compoundV3Repay(address instance, address asset, uint256 amount) external payable {
        amount = Math.min(amount, ERC20(asset).balanceOf(address(this)));

        require(amount != 0, ErrorsLib.ZERO_AMOUNT);

        _approveMaxTo(asset, instance);

        // Compound V3 uses signed accounting: supplying to a negative balance actually repays the borrow position.
        ICompoundV3(instance).supplyTo(_initiator, asset, amount);
    }

    /// @notice Withdraws `amount` of `asset` on the CompoundV3 `instance`.
    /// @dev Initiator must have previously transferred their CompoundV3 position to the bundler.
    /// @dev Assumes the given instance is a CompoundV3 instance.
    /// @dev Pass in `type(uint256).max` to withdraw all.
    function compoundV3Withdraw(address instance, address asset, uint256 amount) external payable {
        ICompoundV3(instance).withdraw(asset, amount);
    }

    /// @notice Withdraws `amount` of `asset` from the CompoundV3 `instance`, on behalf of the initiator.
    /// @notice Warning: should only be called via the bundler's `multicall` function.
    /// @dev Initiator must have previously approved the bundler to manage their CompoundV3 position.
    /// @dev Assumes the given instance is a CompoundV3 instance.
    /// @dev Pass in `type(uint256).max` to withdraw all.
    function compoundV3WithdrawFrom(address instance, address asset, uint256 amount) external payable {
        ICompoundV3(instance).withdrawFrom(_initiator, address(this), asset, amount);
    }

    /// @notice Approves the bundler to act on behalf of the initiator on the CompoundV3 `instance`, given a signed
    /// EIP-712 approval message.
    /// @notice Warning: should only be called via the bundler's `multicall` function.
    /// @dev Assumes the given instance is a CompoundV3 instance.
    function compoundV3AllowBySig(
        address instance,
        bool isAllowed,
        uint256 nonce,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external payable {
        ICompoundV3(instance).allowBySig(_initiator, address(this), isAllowed, nonce, expiry, v, r, s);
    }
}
