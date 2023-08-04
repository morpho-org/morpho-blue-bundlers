// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.21;

import {IBalancerFlashLender} from "./interfaces/IBalancerFlashLender.sol";
import {IBalancerFlashBorrower} from "./interfaces/IBalancerFlashBorrower.sol";

import {Errors} from "./libraries/Errors.sol";

import {SafeTransferLib, ERC20} from "@solmate/utils/SafeTransferLib.sol";

import {BaseBulker} from "./BaseBulker.sol";

contract BalancerBulker is BaseBulker, IBalancerFlashBorrower {
    using SafeTransferLib for ERC20;

    /* IMMUTABLES */

    IBalancerFlashLender internal immutable _BALANCER_VAULT;

    /* CONSTRUCTOR */

    constructor(address balancerVault) {
        require(balancerVault != address(0), Errors.ZERO_ADDRESS);

        _BALANCER_VAULT = IBalancerFlashLender(balancerVault);
    }

    /* EXTERNAL */

    function receiveFlashLoan(
        address[] calldata assets,
        uint256[] calldata amounts,
        uint256[] calldata fees,
        bytes calldata data
    ) external callback(data) {
        for (uint256 i; i < assets.length; ++i) {
            ERC20(assets[i]).safeTransfer(msg.sender, amounts[i] + fees[i]);
        }
    }

    /* ACTIONS */

    /// @dev Triggers a flash loan on Balancer.
    function balancerFlashLoan(address[] calldata assets, uint256[] calldata amounts, bytes calldata data) external {
        _BALANCER_VAULT.flashLoan(address(this), assets, amounts, data);
    }
}