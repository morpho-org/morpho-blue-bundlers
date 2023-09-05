// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.21;

import {IPool} from "@aave/v3-core/interfaces/IPool.sol";
import {IAToken} from "@aave/v3-core/interfaces/IAToken.sol";

import {MigrationBundler} from "./MigrationBundler.sol";
import {ERC20Bundler} from "../ERC20Bundler.sol";

contract AaveV3MigrationBundler is MigrationBundler, ERC20Bundler {
    IPool public immutable AAVE_V3_POOL;

    constructor(address morpho, address aaveV3Pool) MigrationBundler(morpho) {
        AAVE_V3_POOL = IPool(aaveV3Pool);
    }

    /// @dev This function is payable because it’s delegate called by the multicall function (which is payable).
    function aaveV3Withdraw(address asset, uint256 amount, address to) external payable {
        AAVE_V3_POOL.withdraw(asset, amount, to);
    }

    /// @dev This function is payable because it’s delegate called by the multicall function (which is payable).
    function aaveV3Repay(address asset, uint256 amount, uint256 interestRateMode) external payable {
        _approveMaxTo(asset, address(AAVE_V3_POOL));

        AAVE_V3_POOL.repay(asset, amount, interestRateMode, _initiator);
    }

    /// @dev This function is payable because it’s delegate called by the multicall function (which is payable).
    function aaveV3PermitAToken(address aToken, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s)
        external
        payable
    {
        IAToken(aToken).permit(_initiator, address(this), value, deadline, v, r, s);
    }
}
