// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.21;

import {MainnetLib} from "./libraries/MainnetLib.sol";

import {StEthBundler} from "../StEthBundler.sol";

/// @title EthereumStEthBundler
/// @author Morpho Labs
/// @custom:contact security@morpho.org
/// @notice StEthBundler contract specific to the Ethereum.
abstract contract EthereumStEthBundler is StEthBundler {
    /* CONSTRUCTOR */

    constructor() StEthBundler(MainnetLib.ST_ETH, MainnetLib.WST_ETH) {}
}
