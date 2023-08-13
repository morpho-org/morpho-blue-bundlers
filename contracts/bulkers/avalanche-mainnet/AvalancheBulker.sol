// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.21;

import {MorphoBulker} from "../MorphoBulker.sol";
import {ERC20Bulker} from "../ERC20Bulker.sol";
import {WNativeBulker} from "../WNativeBulker.sol";

contract AvalancheBulker is ERC20Bulker, WNativeBulker, MorphoBulker {
    constructor(address morpho) WNativeBulker(0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7) MorphoBulker(morpho) {}
}
