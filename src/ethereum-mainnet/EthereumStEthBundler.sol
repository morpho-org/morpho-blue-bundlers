// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.21;

import "./libraries/ConstantsLib.sol";

import {StEthBundler} from "../StEthBundler.sol";

/// @title EthereumStEthBundler
/// @author Morpho Labs
/// @custom:contact security@morpho.org
/// @notice StEthBundler contract specific to the Ethereum mainnet.
abstract contract EthereumStEthBundler is StEthBundler {
    /* CONSTRUCTOR */

    constructor() StEthBundler(ST_ETH_MAINNET, WST_ETH_MAINNET) {}
}
