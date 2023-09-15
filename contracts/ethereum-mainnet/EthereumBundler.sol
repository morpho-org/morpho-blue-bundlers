// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.21;

import "./libraries/ConstantsLib.sol";

import {EVMBundler} from "../EVMBundler.sol";
import {StEthBundler} from "./StEthBundler.sol";
import {WNativeBundler} from "../WNativeBundler.sol";

/// @title EthereumBundler
/// @author Morpho Labs
/// @custom:contact security@morpho.org
/// @notice Bundler contract specific to the Ethereum mainnet.
contract EthereumBundler is EVMBundler, WNativeBundler, StEthBundler {
    /* CONSTRUCTOR */

    constructor(address urd, address morpho) EVMBundler(urd, morpho) WNativeBundler(WETH) {}
}
