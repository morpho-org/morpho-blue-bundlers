// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.21;

import {MorphoBundler} from "../MorphoBundler.sol";
import {ERC4626Bundler} from "../ERC4626Bundler.sol";
import {ERC20Bundler} from "../ERC20Bundler.sol";

import {ILendingPool} from "@morpho-v1/aave-v2/interfaces/aave/ILendingPool.sol";

import {SafeTransferLib, ERC20} from "@solmate/utils/SafeTransferLib.sol";

contract AaveV2MigrationBundler is MorphoBundler, ERC4626Bundler, ERC20Bundler {
    using SafeTransferLib for ERC20;

    ILendingPool immutable AAVE_V2_POOl;

    constructor(address morpho, address aaveV2Pool) MorphoBundler(morpho) {
        AAVE_V2_POOl = ILendingPool(aaveV2Pool);
    }

    function aaveV3Withdraw(address asset, address to) external {
        AAVE_V2_POOl.withdraw(asset, type(uint256).max, to);
    }

    function aaveV3Repay(address asset, uint256 rateMode) external {
        _approveMaxAaveV2Pool(asset);

        AAVE_V2_POOl.repay(asset, type(uint256).max, rateMode, _initiator);
    }

    function _approveMaxAaveV2Pool(address asset) internal {
        if (ERC20(asset).allowance(address(this), address(AAVE_V2_POOl)) == 0) {
            ERC20(asset).safeApprove(address(AAVE_V2_POOl), type(uint256).max);
        }
    }
}
