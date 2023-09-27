// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.21;

import {MainnetLib} from "./libraries/MainnetLib.sol";

import {UrdBundler} from "../UrdBundler.sol";
import {MorphoBundler} from "../MorphoBundler.sol";
import {EthereumStEthBundler} from "./EthereumStEthBundler.sol";
import {BaseBundler} from "../BaseBundler.sol";

/// @title EthereumBundler
/// @author Morpho Labs
/// @custom:contact security@morpho.org
/// @notice Bundler contract specific to the Ethereum mainnet.
contract EthereumBundler is BaseBundler, EthereumStEthBundler, MorphoBundler, UrdBundler {
    /* CONSTRUCTOR */

    constructor(address morpho) BaseBundler(MainnetLib.WETH) MorphoBundler(morpho) {}
}
