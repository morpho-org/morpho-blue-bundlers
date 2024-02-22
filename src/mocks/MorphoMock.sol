// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {Morpho} from "../../lib/public-allocator/lib/metamorpho/lib/morpho-blue/src/Morpho.sol";

contract MorphoMock is Morpho {
    constructor(address owner) Morpho(owner) {}
}
