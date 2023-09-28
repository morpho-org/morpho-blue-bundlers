// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.21;

import {GoerliLib} from "./libraries/GoerliLib.sol";

import {PermitBundler} from "../PermitBundler.sol";
import {Permit2Bundler} from "../Permit2Bundler.sol";
import {ERC4626Bundler} from "../ERC4626Bundler.sol";
import {WNativeBundler} from "../WNativeBundler.sol";
import {WstEthBundler} from "../WstEthBundler.sol";
import {UrdBundler} from "../UrdBundler.sol";
import {MorphoBundler} from "../MorphoBundler.sol";

/// @title GoerliBundler
/// @author Morpho Labs
/// @custom:contact security@morpho.org
/// @notice Bundler contract specific to the Goerli testnet.
contract GoerliBundler is
    PermitBundler,
    Permit2Bundler,
    ERC4626Bundler,
    WNativeBundler,
    WstEthBundler,
    UrdBundler,
    MorphoBundler
{
    /* CONSTRUCTOR */

    constructor(address morpho)
        WNativeBundler(GoerliLib.WETH)
        WstEthBundler(GoerliLib.ST_ETH, GoerliLib.WST_ETH)
        MorphoBundler(morpho)
    {}
}
