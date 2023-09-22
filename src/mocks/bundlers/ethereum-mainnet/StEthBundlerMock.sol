// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "../../../ethereum-mainnet/libraries/ConstantsLib.sol";

import "../../../Permit2Bundler.sol";
import "../../../StEthBundler.sol";

contract StEthBundlerMock is Permit2Bundler, StEthBundler {
    constructor() StEthBundler(ST_ETH_MAINNET, WST_ETH_MAINNET) {}
}
