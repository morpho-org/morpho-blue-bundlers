// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {MainnetLib} from "../../../ethereum-mainnet/libraries/MainnetLib.sol";

import "../../../BaseBundler.sol";
import "../../../StEthBundler.sol";

contract StEthBundlerMock is BaseBundler, StEthBundler {
    constructor() StEthBundler(MainnetLib.ST_ETH, MainnetLib.WST_ETH) BaseBundler(MainnetLib.WETH) {}
}
