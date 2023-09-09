// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.21;

import {ILendingPool} from "@morpho-v1/aave-v2/interfaces/aave/ILendingPool.sol";

import {ERC20Bundler} from "../ERC20Bundler.sol";
import {MigrationBundler} from "./MigrationBundler.sol";

/// @title AaveV2MigrationBundler
/// @author Morpho Labs
/// @custom:contact security@morpho.xyz
/// @notice Contract allowing to migrate a position from Aave V2 to Morpho Blue easily.
contract AaveV2MigrationBundler is MigrationBundler, ERC20Bundler {
    ILendingPool public immutable AAVE_V2_POOl;

    constructor(address morpho, address aaveV2Pool) MigrationBundler(morpho) {
        AAVE_V2_POOl = ILendingPool(aaveV2Pool);
    }

    function aaveV2Withdraw(address asset, uint256 amount, address to) external payable {
        AAVE_V2_POOl.withdraw(asset, amount, to);
    }

    function aaveV2Repay(address asset, uint256 amount, uint256 rateMode) external payable {
        _approveMaxTo(asset, address(AAVE_V2_POOl));

        AAVE_V2_POOl.repay(asset, amount, rateMode, _initiator);
    }
}
