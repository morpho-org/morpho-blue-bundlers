// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.21;

import {MainnetLib} from "./libraries/MainnetLib.sol";

import {PermitBundler} from "../PermitBundler.sol";
import {Permit2Bundler} from "../Permit2Bundler.sol";
import {ERC4626Bundler} from "../ERC4626Bundler.sol";
import {WNativeBundler} from "../WNativeBundler.sol";
import {EthereumWstEthBundler} from "./EthereumWstEthBundler.sol";
import {UrdBundler} from "../UrdBundler.sol";
import {MorphoBundler} from "../MorphoBundler.sol";

/// @title EthereumBundler
/// @author Morpho Labs
/// @custom:contact security@morpho.org
/// @notice Bundler contract specific to the Ethereum mainnet.
contract EthereumBundler is
    PermitBundler,
    Permit2Bundler,
    ERC4626Bundler,
    WNativeBundler,
    EthereumWstEthBundler,
    UrdBundler,
    MorphoBundler
{
    /* CONSTRUCTOR */

    constructor(address morpho) WNativeBundler(MainnetLib.WETH) MorphoBundler(morpho) {}
}
