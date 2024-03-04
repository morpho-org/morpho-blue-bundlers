// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.24;

import {SafeTransferLib, ERC20} from "../../lib/solmate/src/utils/SafeTransferLib.sol";

import {BaseBundler} from "../BaseBundler.sol";
import {TransferBundler} from "../TransferBundler.sol";
import {PermitBundler} from "../PermitBundler.sol";
import {Permit2Bundler} from "../Permit2Bundler.sol";
import {ERC4626Bundler} from "../ERC4626Bundler.sol";
import {MorphoBundlerV2} from "../MorphoBundlerV2.sol";

/// @title MigrationBundlerV2
/// @author Morpho Labs
/// @custom:contact security@morpho.org
/// @notice Abstract contract allowing to migrate a position from one lending protocol to Morpho Blue easily.
abstract contract MigrationBundlerV2 is
    TransferBundler,
    PermitBundler,
    Permit2Bundler,
    ERC4626Bundler,
    MorphoBundlerV2
{
    using SafeTransferLib for ERC20;

    /* CONSTRUCTOR */

    constructor(address morpho) MorphoBundlerV2(morpho) {}

    /* INTERNAL */

    /// @inheritdoc MorphoBundlerV2
    function _isSenderAuthorized() internal view virtual override(BaseBundler, MorphoBundlerV2) returns (bool) {
        return MorphoBundlerV2._isSenderAuthorized();
    }
}
