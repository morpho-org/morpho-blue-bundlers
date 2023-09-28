// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.21;

import {MainnetLib} from "./libraries/MainnetLib.sol";

import {WstEthBundler} from "../WstEthBundler.sol";

/// @title EthereumWstEthBundler
/// @author Morpho Labs
/// @custom:contact security@morpho.org
/// @notice WstEthBundler contract specific to the Ethereum mainnet.
abstract contract EthereumWstEthBundler is WstEthBundler {
    /* CONSTRUCTOR */

    constructor() WstEthBundler(MainnetLib.ST_ETH, MainnetLib.WST_ETH) {}
}
