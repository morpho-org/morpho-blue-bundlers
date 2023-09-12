// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.21;

import {ILendingPool} from "@morpho-v1/aave-v2/interfaces/aave/ILendingPool.sol";

import {Permit2Bundler} from "../Permit2Bundler.sol";
import {MigrationBundler} from "./MigrationBundler.sol";

/// @title AaveV2MigrationBundler
/// @author Morpho Labs
/// @custom:contact security@morpho.org
/// @notice Contract allowing to migrate a position from Aave V2 to Morpho Blue easily.
contract AaveV2MigrationBundler is MigrationBundler, Permit2Bundler {
    /* IMMUTABLES */

    ILendingPool public immutable AAVE_V2_POOl;

    /* CONSTRUCTOR */

    constructor(address morpho, address aaveV2Pool) MigrationBundler(morpho) {
        AAVE_V2_POOl = ILendingPool(aaveV2Pool);
    }

    /* ACTIONS */

    function aaveV2Withdraw(address asset, uint256 amount, address to) external payable {
        AAVE_V2_POOl.withdraw(asset, amount, to);
    }

    function aaveV2Repay(address asset, uint256 amount, uint256 rateMode) external payable {
        _approveMaxTo(asset, address(AAVE_V2_POOl));

        AAVE_V2_POOl.repay(asset, amount, rateMode, _initiator);
    }
}
