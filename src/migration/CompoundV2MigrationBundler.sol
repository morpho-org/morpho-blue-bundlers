// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.21;

import {ICEth} from "./interfaces/ICEth.sol";
import {ICToken} from "./interfaces/ICToken.sol";

import {Math} from "../../lib/morpho-utils/src/math/Math.sol";
import {ErrorsLib} from "../libraries/ErrorsLib.sol";

import {BaseBundler} from "../BaseBundler.sol";
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
    /// @dev Initiator must have previously transferred their assets to the bundler.
    /// @param cToken The address of the cToken contract
    /// @param amount The amount of `cToken` to repay.
    /// Pass `type(uint256).max - 1` to repay the bundler's balance of underlying (except for cETH).
    /// Pass `type(uint256).max` to repay the initiator's debt and interest (except for cETH).
    function compoundV2Repay(address cToken, uint256 amount) external payable protected {
        if (cToken == C_ETH) {
            address _initiator = initiator();

            amount = Math.min(amount, address(this).balance);
            amount = Math.min(amount, ICEth(C_ETH).borrowBalanceCurrent(_initiator));

            require(amount != 0, ErrorsLib.ZERO_AMOUNT);

            ICEth(C_ETH).repayBorrowBehalf{value: amount}(_initiator);
        } else {
            address underlying = ICToken(cToken).underlying();

            if (amount != type(uint256).max) amount = Math.min(amount, ERC20(underlying).balanceOf(address(this)));

            require(amount != 0, ErrorsLib.ZERO_AMOUNT);

            _approveMaxTo(underlying, cToken);

            ICToken(cToken).repayBorrowBehalf(initiator(), amount);
        }
    }

    /// @notice Redeems `amount` of `cToken` from CompoundV2.
    /// @notice Withdrawn assets are received by the bundler and should be used afterwards.
    /// @dev Initiator must have previously transferred their cTokens to the bundler.
    /// @param cToken The address of the cToken contract
    /// @param amount The amount of `cToken` to redeem. Pass `type(uint256).max` to redeem the bundler's `cToken`
    /// balance.
    function compoundV2Redeem(address cToken, uint256 amount) external payable protected {
        amount = Math.min(amount, ERC20(cToken).balanceOf(address(this)));

        require(amount != 0, ErrorsLib.ZERO_AMOUNT);

        ICToken(cToken).redeem(amount);
    }

    /* INTERNAL */

    /// @inheritdoc MigrationBundler
    function _isSenderAuthorized() internal view override(BaseBundler, MigrationBundler) returns (bool) {
        return MigrationBundler._isSenderAuthorized();
    }
}
