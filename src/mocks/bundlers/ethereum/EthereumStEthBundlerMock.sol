// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "../../../TransferBundler.sol";
import "../../../Permit2Bundler.sol";
import "../../../ethereum/EthereumStEthBundler.sol";

contract EthereumStEthBundlerMock is TransferBundler, Permit2Bundler, EthereumStEthBundler {}
