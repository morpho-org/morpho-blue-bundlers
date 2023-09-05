// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.21;

import {Permit2Bundler} from "./Permit2Bundler.sol";
import {ERC4626Bundler} from "./ERC4626Bundler.sol";
import {MorphoBundler} from "./MorphoBundler.sol";

/// @title EVMBundler
/// @author Morpho Labs
/// @custom:contact security@morpho.xyz
/// @notice Common bundler layer guaranteeing it can be deployed to the same address on all EVM-compatible chains.
contract EVMBundler is Permit2Bundler, ERC4626Bundler, MorphoBundler {
    constructor(address morpho) MorphoBundler(morpho) {}
}
