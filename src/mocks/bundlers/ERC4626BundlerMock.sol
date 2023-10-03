// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "../../ERC4626Bundler.sol";
import "../../TransferBundler.sol";

contract ERC4626BundlerMock is TransferBundler, ERC4626Bundler {}
