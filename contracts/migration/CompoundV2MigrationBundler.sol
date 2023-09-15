// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.21;

import {ICEth} from "./interfaces/ICEth.sol";
import {ICToken} from "./interfaces/ICToken.sol";
import {IWNative} from "../interfaces/IWNative.sol";

import {ErrorsLib} from "./libraries/ErrorsLib.sol";

import {Permit2Bundler} from "../Permit2Bundler.sol";
import {MigrationBundler} from "./MigrationBundler.sol";

/// @title CompoundV2MigrationBundler
/// @author Morpho Labs
/// @custom:contact security@morpho.org
/// @notice Contract allowing to migrate a position from Compound V2 to Morpho Blue easily.
contract CompoundV2MigrationBundler is MigrationBundler, Permit2Bundler {
    /* IMMUTABLES */

    ICEth public immutable C_NATIVE;
    IWNative public immutable WRAPPED_NATIVE;

    /* CONSTRUCTOR */

    constructor(address morpho, address wNative, address cNative) MigrationBundler(morpho) {
        WRAPPED_NATIVE = IWNative(wNative);
        C_NATIVE = ICEth(cNative);
    }

    /* CALLBACKS */

    /// @dev Only the wNative contract or CompoundV2 is allowed to transfer the native token to this contract, without
    /// any calldata.
    receive() external payable {
        require(msg.sender == address(WRAPPED_NATIVE) || msg.sender == address(C_NATIVE), ErrorsLib.UNAUTHORIZED_SENDER);
    }

    /* ACTIONS */

    /// @notice Repays `amount` of `cToken`'s underlying asset, on behalf of the initiator.
    /// @notice Warning: should only be called via the bundler's `multicall` function.
    function compoundV2Repay(address cToken, uint256 amount) external payable {
        if (cToken == address(C_NATIVE)) {
            WRAPPED_NATIVE.withdraw(amount);

            // Reverts in case of error.
            C_NATIVE.repayBorrowBehalf{value: amount}(_initiator);
        } else {
            _approveMaxTo(ICToken(cToken).underlying(), cToken);

            // Doesn't revert in case of error.
            uint256 err = ICToken(cToken).repayBorrowBehalf(_initiator, amount);
            require(err == 0, ErrorsLib.REPAY_ERROR);
        }
    }

    /// @notice Redeems `amount` of `cToken`'s underlying asset from CompoundV2.
    /// @dev Initiator must have previously transferred their cTokens to the bundler.
    function compoundV2Redeem(address cToken, uint256 amount) external payable {
        uint256 err = ICToken(cToken).redeemUnderlying(amount);
        require(err == 0, ErrorsLib.REDEEM_ERROR);

        if (cToken == address(C_NATIVE)) WRAPPED_NATIVE.deposit{value: amount}();
    }
}
