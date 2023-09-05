// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.21;

import {ICompoundV3} from "./interfaces/ICompoundV3.sol";

import {MigrationBundler} from "./MigrationBundler.sol";
import {ERC20Bundler} from "../ERC20Bundler.sol";

contract CompoundV3MigrationBundler is MigrationBundler, ERC20Bundler {
    constructor(address morpho) MigrationBundler(morpho) {}

    /// @dev This function is payable because it’s delegate called by the multicall function (which is payable).
    function compoundV3Supply(address instance, address asset, uint256 amount) external payable {
        _approveMaxTo(asset, instance);
        ICompoundV3(instance).supplyTo(_initiator, asset, amount);
    }

    /// @dev This function is payable because it’s delegate called by the multicall function (which is payable).
    function compoundV3Withdraw(address instance, address asset, uint256 amount) external payable {
        ICompoundV3(instance).withdraw(asset, amount);
    }

    /// @dev This function is payable because it’s delegate called by the multicall function (which is payable).
    function compoundV3WithdrawFrom(address instance, address to, address asset, uint256 amount) external payable {
        ICompoundV3(instance).withdrawFrom(_initiator, to, asset, amount);
    }

    /// @dev This function is payable because it’s delegate called by the multicall function (which is payable).
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