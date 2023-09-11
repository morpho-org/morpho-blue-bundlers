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

    /* ACTIONS */

    function compoundV2Repay(address cToken, uint256 repayAmount) external payable {
        if (cToken == address(C_NATIVE)) {
            WRAPPED_NATIVE.withdraw(repayAmount);

            // Reverts in case of error.
            C_NATIVE.repayBorrowBehalf{value: repayAmount}(_initiator);
        } else {
            _approveMaxTo(ICToken(cToken).underlying(), cToken);

            // Doesn't revert in case of error.
            uint256 err = ICToken(cToken).repayBorrowBehalf(_initiator, repayAmount);
            require(err == 0, ErrorsLib.REPAY_ERROR);
        }
    }

    function compoundV2Redeem(address cToken, uint256 amount) external payable {
        uint256 err = ICToken(cToken).redeemUnderlying(amount);
        require(err == 0, ErrorsLib.REDEEM_ERROR);

        if (cToken == address(C_NATIVE)) WRAPPED_NATIVE.deposit{value: amount}();
    }

    receive() external payable {
        require(msg.sender == address(WRAPPED_NATIVE) || msg.sender == address(C_NATIVE), ErrorsLib.UNAUTHORIZED_SENDER);
    }
}
