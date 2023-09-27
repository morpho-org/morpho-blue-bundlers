// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.21;

import {GoerliLib} from "./libraries/GoerliLib.sol";

import {UrdBundler} from "../UrdBundler.sol";
import {StEthBundler} from "../StEthBundler.sol";
import {MorphoBundler} from "../MorphoBundler.sol";
import {BaseBundler} from "../BaseBundler.sol";

/// @title GoerliBundler
/// @author Morpho Labs
/// @custom:contact security@morpho.org
/// @notice Bundler contract specific to the Goerli testnet.
contract GoerliBundler is BaseBundler, StEthBundler, MorphoBundler, UrdBundler {
    /* CONSTRUCTOR */

    constructor(address morpho)
        BaseBundler(GoerliLib.WETH)
        StEthBundler(GoerliLib.ST_ETH, GoerliLib.WST_ETH)
        MorphoBundler(morpho)
    {}
}
