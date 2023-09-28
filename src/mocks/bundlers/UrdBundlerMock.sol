// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "../../UrdBundler.sol";
import "../../BaseBundler.sol";

contract UrdBundlerMock is UrdBundler {
    constructor(address morpho) BaseBundler(morpho) {}
}
