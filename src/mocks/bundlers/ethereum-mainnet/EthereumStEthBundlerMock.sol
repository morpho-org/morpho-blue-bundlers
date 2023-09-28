// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "../../../Permit2Bundler.sol";
import "../../../ethereum-mainnet/EthereumStEthBundler.sol";

contract EthereumStEthBundlerMock is Permit2Bundler, EthereumStEthBundler {}
