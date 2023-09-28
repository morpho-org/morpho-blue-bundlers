// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.21;

import {MainnetLib} from "./libraries/MainnetLib.sol";

import {WNativeBundler} from "../WNativeBundler.sol";
import {EthereumStEthBundler} from "./EthereumStEthBundler.sol";
import {UrdBundler} from "../UrdBundler.sol";
import {BaseBundler} from "../BaseBundler.sol";

/// @title EthereumBundler
/// @author Morpho Labs
/// @custom:contact security@morpho.org
/// @notice Bundler contract specific to the Ethereum mainnet.
contract EthereumBundler is WNativeBundler, EthereumStEthBundler, UrdBundler {
    /* CONSTRUCTOR */

    constructor(address morpho) WNativeBundler(MainnetLib.WETH) BaseBundler(morpho) {}
}
