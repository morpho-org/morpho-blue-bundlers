// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.21;

import {ICompoundV3} from "./interfaces/ICompoundV3.sol";

import {Math} from "../../lib/morpho-utils/src/math/Math.sol";
import {ErrorsLib} from "../libraries/ErrorsLib.sol";

import {MigrationBundler, ERC20} from "./MigrationBundler.sol";

/// @title CompoundV3MigrationBundler
/// @author Morpho Labs
/// @custom:contact security@morpho.org
/// @notice Contract allowing to migrate a position from Compound V3 to Morpho Blue easily.
contract CompoundV3MigrationBundler is MigrationBundler {
    /* CONSTRUCTOR */

    constructor(address morpho) MigrationBundler(morpho) {}

    /* ACTIONS */

    /// @notice Repays `amount` on the CompoundV3 `instance`, on behalf of the initiator.
    /// @dev Assumes the given `instance` is a CompoundV3 instance.
    /// @dev Pass `amount = type(uint256).max` to repay all.
    function compoundV3Repay(address instance, uint256 amount) external payable onlyInitiated {
        address initiator = initiator();
        address asset = ICompoundV3(instance).baseToken();

        amount = Math.min(amount, ERC20(asset).balanceOf(address(this)));
        amount = Math.min(amount, ICompoundV3(instance).borrowBalanceOf(initiator));

        require(amount != 0, ErrorsLib.ZERO_AMOUNT);

        _approveMaxTo(asset, instance);

        // Compound V3 uses signed accounting: supplying to a negative balance actually repays the borrow position.
        ICompoundV3(instance).supplyTo(initiator, asset, amount);
    }

    /// @notice Withdraws `amount` of `asset` from the CompoundV3 `instance`, on behalf of the initiator.
    /// @dev Initiator must have previously approved the bundler to manage their CompoundV3 position.
    /// @dev Assumes the given `instance` is a CompoundV3 instance.
    /// @dev Pass `amount = type(uint256).max` to withdraw all.
    function compoundV3WithdrawFrom(address instance, address asset, uint256 amount) external payable onlyInitiated {
        address initiator = initiator();
        uint256 balance = asset == ICompoundV3(instance).baseToken()
            ? ICompoundV3(instance).balanceOf(initiator)
            : ICompoundV3(instance).userCollateral(initiator, asset);

        amount = Math.min(amount, balance);

        require(amount != 0, ErrorsLib.ZERO_AMOUNT);

        ICompoundV3(instance).withdrawFrom(initiator, address(this), asset, amount);
    }

    /// @notice Approves the bundler to act on behalf of the initiator on the CompoundV3 `instance`, given a signed
    /// EIP-712 approval message.
    /// @dev Assumes the given `instance` is a CompoundV3 instance.
    function compoundV3AllowBySig(
        address instance,
        bool isAllowed,
        uint256 nonce,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external payable onlyInitiated {
        ICompoundV3(instance).allowBySig(initiator(), address(this), isAllowed, nonce, expiry, v, r, s);
    }
}
