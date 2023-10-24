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

    address public immutable C_ETH;

    /* CONSTRUCTOR */

    constructor(address morpho, address wNative, address cEth) WNativeBundler(wNative) MigrationBundler(morpho) {
        C_ETH = cEth;
    }

    /* CALLBACKS */

    /// @dev Only the wNative contract or CompoundV2 is allowed to transfer the native tokens to this contract, without
    /// any calldata.
    receive() external payable override {
        require(msg.sender == WRAPPED_NATIVE || msg.sender == C_ETH, ErrorsLib.UNAUTHORIZED_SENDER);
    }

    /* ACTIONS */

    /// @notice Repays `amount` of `cToken`'s underlying asset, on behalf of the initiator.
    /// @notice Warning: should only be called via the bundler's `multicall` function.
    /// @dev Pass `amount = type(uint256).max` to repay all.
    function compoundV2Repay(address cToken, uint256 amount) external payable {
        if (cToken == C_ETH) {
            if (amount != type(uint256).max) amount = Math.min(amount, address(this).balance);

            require(amount != 0, ErrorsLib.ZERO_AMOUNT);

            ICEth(C_ETH).repayBorrowBehalf{value: amount}(initiator());
        } else {
            address underlying = ICToken(cToken).underlying();

            if (amount != type(uint256).max) amount = Math.min(amount, ERC20(underlying).balanceOf(address(this)));

            require(amount != 0, ErrorsLib.ZERO_AMOUNT);

            _approveMaxTo(underlying, cToken);

            // Doesn't revert in case of error.
            uint256 err = ICToken(cToken).repayBorrowBehalf(initiator(), amount);
            require(err == 0, ErrorsLib.REPAY_ERROR);
        }
    }

    /// @notice Redeems `amount` of `cToken` from CompoundV2.
    /// @dev Initiator must have previously transferred their cTokens to the bundler.
    /// @dev Pass `amount = type(uint256).max` to redeem all.
    function compoundV2Redeem(address cToken, uint256 amount) external payable {
        amount = Math.min(amount, ERC20(cToken).balanceOf(address(this)));

        require(amount != 0, ErrorsLib.ZERO_AMOUNT);

        // Doesn't revert in case of error.
        uint256 err = ICToken(cToken).redeem(amount);
        require(err == 0, ErrorsLib.REDEEM_ERROR);
    }
}
