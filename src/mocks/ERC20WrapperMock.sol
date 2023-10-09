// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {IERC20} from "@openzeppelin/token/ERC20/IERC20.sol";
import {ERC20} from "@openzeppelin/token/ERC20/ERC20.sol";
import {ERC20Wrapper} from "@openzeppelin/token/ERC20/extensions/ERC20Wrapper.sol";

contract ERC20WrapperMock is ERC20Wrapper {
    constructor(address asset) ERC20Wrapper(IERC20(asset)) ERC20("Wrapper", "W") {}
}
