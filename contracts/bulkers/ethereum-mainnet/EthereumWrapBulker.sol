// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.21;

import {MorphoBulker} from "../MorphoBulker.sol";
import {ERC20Bulker} from "../ERC20Bulker.sol";
import {WNativeBulker} from "../WNativeBulker.sol";
import {StEthBulker} from "./StEthBulker.sol";

contract EthereumWrapBulker is ERC20Bulker, WNativeBulker, StEthBulker, MorphoBulker {
    address internal constant _WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    constructor(address morpho) WNativeBulker(_WETH) MorphoBulker(morpho) {}
}
