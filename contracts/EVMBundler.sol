// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.21;

import {URDBundler} from "./URDBundler.sol";
import {MorphoBundler} from "./MorphoBundler.sol";
import {PermitBundler} from "./PermitBundler.sol";
import {Permit2Bundler} from "./Permit2Bundler.sol";
import {ERC4626Bundler} from "./ERC4626Bundler.sol";

/// @title EVMBundler
/// @author Morpho Labs
/// @custom:contact security@morpho.org
/// @notice Common bundler layer guaranteeing it can be deployed to the same address on all EVM-compatible chains.
contract EVMBundler is PermitBundler, ERC4626Bundler, URDBundler, MorphoBundler {
    constructor(address urd, address morpho) URDBundler(urd) MorphoBundler(morpho) {}
}
