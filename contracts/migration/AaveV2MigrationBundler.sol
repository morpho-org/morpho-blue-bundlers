// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.21;

import {ILendingPool} from "@morpho-v1/aave-v2/interfaces/aave/ILendingPool.sol";

import {MigrationBundler} from "./MigrationBundler.sol";
import {ERC20Bundler} from "../ERC20Bundler.sol";

contract AaveV2MigrationBundler is MigrationBundler, ERC20Bundler {
    ILendingPool public immutable AAVE_V2_POOl;

    constructor(address morpho, address aaveV2Pool) MigrationBundler(morpho) {
        AAVE_V2_POOl = ILendingPool(aaveV2Pool);
    }

    /// @dev This function is payable because it’s delegate called by the multicall function (which is payable).
    function aaveV2Withdraw(address asset, uint256 amount, address to) external payable {
        AAVE_V2_POOl.withdraw(asset, amount, to);
    }

    /// @dev This function is payable because it’s delegate called by the multicall function (which is payable).
    function aaveV2Repay(address asset, uint256 amount, uint256 rateMode) external payable {
        _approveMaxTo(asset, address(AAVE_V2_POOl));

        AAVE_V2_POOl.repay(asset, amount, rateMode, _initiator);
    }
}
