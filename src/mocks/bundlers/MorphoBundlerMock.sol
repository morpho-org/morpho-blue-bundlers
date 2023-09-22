// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "../../MorphoBundler.sol";

contract MorphoBundlerMock is MorphoBundler {
    constructor(address morpho) MorphoBundler(morpho) {}
}
