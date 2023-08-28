// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.21;

import {MorphoBundler} from "../MorphoBundler.sol";
import {ERC4626Bundler} from "../ERC4626Bundler.sol";

import {ICompoundV3} from "../interfaces/compound-v3/ICompoundV3.sol";

import {SafeTransferLib, ERC20} from "@solmate/utils/SafeTransferLib.sol";

contract CompoundV3MigrationBundler is MorphoBundler, ERC4626Bundler {
    using SafeTransferLib for ERC20;

    constructor(address morpho) MorphoBundler(morpho) {}

    function compoundV3AllowBySig(
        address instance,
        bool isAllowed,
        uint256 nonce,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        ICompoundV3(instance).allowBySig(_initiator, address(this), isAllowed, nonce, expiry, v, r, s);
    }

    function _approveMaxCompoundV3(address instance, address asset) internal {
        if (ERC20(asset).allowance(address(this), instance) == 0) {
            ERC20(asset).safeApprove(instance, type(uint256).max);
        }
    }
}
