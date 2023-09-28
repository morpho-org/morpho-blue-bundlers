// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {MainnetLib} from "../../../ethereum/libraries/MainnetLib.sol";

import "../../../Permit2Bundler.sol";
import "../../../StEthBundler.sol";

contract StEthBundlerMock is Permit2Bundler, StEthBundler {
    constructor() StEthBundler(MainnetLib.ST_ETH, MainnetLib.WST_ETH) {}
}
