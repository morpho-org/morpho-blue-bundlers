// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.21;

import {BaseBundler} from "./BaseBundler.sol";
import {MorphoBundler} from "./MorphoBundler.sol";
import {ERC20Bundler} from "./ERC20Bundler.sol";

/// @title EVMBundler
/// @author Morpho Labs
/// @custom:contact security@morpho.xyz
/// @notice Common bundler layer guaranteeing it can be deployed to the same address on all EVM-compatible chains.
contract EVMBundler is ERC20Bundler, MorphoBundler {
    constructor(address morpho, address bundlerGateway) MorphoBundler(morpho) BaseBundler(bundlerGateway) {}
}
