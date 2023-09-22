// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "../../../ethereum-mainnet/StEthBundler.sol";
import "../../../Permit2Bundler.sol";

contract StEthBundlerMock is StEthBundler, Permit2Bundler {}
