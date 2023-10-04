// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {IERC20} from "@bundlers/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {ERC20} from "@bundlers/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {ERC4626} from "@bundlers/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC4626.sol";

contract ERC4626Mock is ERC4626 {
    constructor(address asset, string memory name, string memory symbol) ERC4626(IERC20(asset)) ERC20(name, symbol) {}
}
