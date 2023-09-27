// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.21;

import {GoerliLib} from "./libraries/GoerliLib.sol";

import {WNativeBundler} from "../WNativeBundler.sol";
import {StEthBundler} from "../StEthBundler.sol";
import {UrdBundler} from "../UrdBundler.sol";
import {MorphoBundler} from "../MorphoBundler.sol";

/// @title GoerliBundler
/// @author Morpho Labs
/// @custom:contact security@morpho.org
/// @notice Bundler contract specific to the Goerli testnet.
contract GoerliBundler is WNativeBundler, StEthBundler, UrdBundler, MorphoBundler {
    /* CONSTRUCTOR */

    constructor(address morpho)
        WNativeBundler(GoerliLib.WETH)
        StEthBundler(GoerliLib.ST_ETH, GoerliLib.WST_ETH)
        MorphoBundler(morpho)
    {}
}
