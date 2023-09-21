// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "../../PermitBundler.sol";
import "../../Permit2Bundler.sol";

contract PermitBundlerMock is PermitBundler, Permit2Bundler {}