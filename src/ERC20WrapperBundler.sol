// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.21;

import {ErrorsLib} from "./libraries/ErrorsLib.sol";
import {Math} from "../lib/morpho-utils/src/math/Math.sol";
import {SafeTransferLib, ERC20} from "../lib/solmate/src/utils/SafeTransferLib.sol";

import {BaseBundler} from "./BaseBundler.sol";
import {ERC20Wrapper} from "../lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Wrapper.sol";

/// @title ERC20WrapperBundler
/// @author Morpho Labs
/// @custom:contact security@morpho.org
/// @notice Enables the wrapping and unwrapping of ERC20 tokens.
abstract contract ERC20WrapperBundler is BaseBundler {
    using SafeTransferLib for ERC20;

    /* WRAPPER ACTIONS */

    /// @notice Deposits underlying tokens and mints the corresponding amount of wrapped tokens to the initiator.
    /// @dev Deposits tokens "for" the `initiator` to conduct the permissionned check. Wrapped tokens must
    /// be sent back to the bundler contract to perform additional actions.
    /// @dev Initiator must have previously transferred their assets to the bundler.
    /// @dev Assumes that `wrapper` implements the `ERC20Wrapper` interface.
    /// @param wrapper The address of the ERC20 wrapper contract.
    /// @param amount The amount of underlying tokens to deposit. Pass `type(uint256).max` to deposit the bundler's
    /// balance.
    function erc20WrapperDepositFor(address wrapper, uint256 amount) external protected {
        ERC20 underlying = ERC20(address(ERC20Wrapper(wrapper).underlying()));

        amount = Math.min(amount, underlying.balanceOf(address(this)));

        require(amount != 0, ErrorsLib.ZERO_AMOUNT);

        _approveMaxTo(address(underlying), wrapper);
        ERC20Wrapper(wrapper).depositFor(initiator(), amount);
    }

    /// @notice Burns a number of wrapped tokens and withdraws the corresponding number of underlying tokens.
    /// @dev Initiator must have previously transferred their wrapped tokens to the bundler.
    /// @dev Assumes that `wrapper` implements the `ERC20Wrapper` interface.
    /// @param wrapper The address of the ERC20 wrapper contract.
    /// @param account The address receiving the underlying tokens.
    /// @param amount The amount of wrapped tokens to burn. Pass `type(uint256).max` to burn the bundler's balance.
    function erc20WrapperWithdrawTo(address wrapper, address account, uint256 amount) external protected {
        require(account != address(0), ErrorsLib.ZERO_ADDRESS);
        require(amount != 0, ErrorsLib.ZERO_AMOUNT);

        ERC20Wrapper(wrapper).withdrawTo(account, amount);
    }
}
