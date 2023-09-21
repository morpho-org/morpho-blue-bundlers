// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.21;

import "./libraries/ConstantsLib.sol";

import {Permit2Bundler} from "../Permit2Bundler.sol";
import {ERC4626Bundler} from "../ERC4626Bundler.sol";
import {UrdBundler} from "../UrdBundler.sol";
import {MorphoBundler} from "../MorphoBundler.sol";
import {WNativeBundler} from "../WNativeBundler.sol";
import {StEthBundler} from "./StEthBundler.sol";

/// @title EthereumBundler
/// @author Morpho Labs
/// @custom:contact security@morpho.org
/// @notice Bundler contract specific to the Ethereum mainnet.
contract EthereumBundler is Permit2Bundler, ERC4626Bundler, WNativeBundler, UrdBundler, MorphoBundler, StEthBundler {
    /* CONSTRUCTOR */

    constructor(address morpho) WNativeBundler(WETH) MorphoBundler(morpho) {}
}
