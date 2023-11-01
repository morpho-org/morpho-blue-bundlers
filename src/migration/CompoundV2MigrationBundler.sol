// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.21;

import {ICEth} from "./interfaces/ICEth.sol";
import {ICToken} from "./interfaces/ICToken.sol";

import {Math} from "../../lib/morpho-utils/src/math/Math.sol";
import {ErrorsLib} from "../libraries/ErrorsLib.sol";

import {WNativeBundler} from "../WNativeBundler.sol";
import {MigrationBundler, ERC20} from "./MigrationBundler.sol";

/// @title CompoundV2MigrationBundler
/// @author Morpho Labs
/// @custom:contact security@morpho.org
/// @notice Contract allowing to migrate a position from Compound V2 to Morpho Blue easily.
contract CompoundV2MigrationBundler is WNativeBundler, MigrationBundler {
    /* IMMUTABLES */

    /// @dev The address of the cETH contract.
    address public immutable C_ETH;

    /* CONSTRUCTOR */

    /// @param morpho The Morpho contract Address.
    /// @param wNative The address of the wNative token contract.
    /// @param cEth The address of the cETH contract.
    constructor(address morpho, address wNative, address cEth) WNativeBundler(wNative) MigrationBundler(morpho) {
        require(cEth != address(0), ErrorsLib.ZERO_ADDRESS);

        C_ETH = cEth;
    }

    /* ACTIONS */

    /// @notice Repays `amount` of `cToken`'s underlying asset, on behalf of the initiator.
    /// @dev Warning: `cToken` can re-enter the bundler flow.
    /// @dev Pass `amount = type(uint256).max` to repay all.
    /// @param cToken The address of the cToken contract
    /// @param amount The amount of `cToken` to repay.
    function compoundV2Repay(address cToken, uint256 amount) external payable onlyInitiated {
        if (cToken == C_ETH) {
            amount = Math.min(amount, address(this).balance);

            require(amount != 0, ErrorsLib.ZERO_AMOUNT);

            ICEth(C_ETH).repayBorrowBehalf{value: amount}(initiator());
        } else {
            address underlying = ICToken(cToken).underlying();

            if (amount != type(uint256).max) amount = Math.min(amount, ERC20(underlying).balanceOf(address(this)));

            require(amount != 0, ErrorsLib.ZERO_AMOUNT);

            _approveMaxTo(underlying, cToken);

            ICToken(cToken).repayBorrowBehalf(initiator(), amount);
        }
    }

    /// @notice Redeems `amount` of `cToken` from CompoundV2.
    /// @dev Initiator must have previously transferred their cTokens to the bundler.
    /// @dev Warning: `cToken` can re-enter the bundler flow.
    /// @dev Pass `amount = type(uint256).max` to redeem all.
    /// @param cToken The address of the cToken contract
    /// @param amount The amount of `cToken` to redeem.
    function compoundV2Redeem(address cToken, uint256 amount) external payable {
        amount = Math.min(amount, ERC20(cToken).balanceOf(address(this)));

        require(amount != 0, ErrorsLib.ZERO_AMOUNT);

        ICToken(cToken).redeem(amount);
    }
}
