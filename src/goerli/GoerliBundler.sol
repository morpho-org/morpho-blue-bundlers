// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.21;

import {GoerliLib} from "./libraries/GoerliLib.sol";

import {PermitBundler} from "../PermitBundler.sol";
import {Permit2Bundler} from "../Permit2Bundler.sol";
import {ERC4626Bundler} from "../ERC4626Bundler.sol";
import {WETHBundler} from "../WETHBundler.sol";
import {StEthBundler} from "../StEthBundler.sol";
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
    WETHBundler,
    StEthBundler,
    UrdBundler,
    MorphoBundler
{
    /* CONSTRUCTOR */

    constructor(address morpho)
        WETHBundler(GoerliLib.WETH)
        StEthBundler(GoerliLib.ST_ETH, GoerliLib.WST_ETH)
        MorphoBundler(morpho)
    {}
}
