// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {MainnetLib} from "../../../ethereum-mainnet/libraries/MainnetLib.sol";

import "../../../Permit2Bundler.sol";
import "../../../WstEthBundler.sol";

contract WstEthBundlerMock is Permit2Bundler, WstEthBundler {
    constructor() WstEthBundler(MainnetLib.ST_ETH, MainnetLib.WST_ETH) {}
}
