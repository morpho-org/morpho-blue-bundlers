// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {ERC20Permit} from "@openzeppelin/token/ERC20/extensions/ERC20Permit.sol";
import {ERC20} from "@openzeppelin/token/ERC20/ERC20.sol";

contract ERC20PermitMock is ERC20Permit {
    constructor(string memory _name, string memory _symbol) ERC20Permit(_name) ERC20(_name, _symbol) {}

    function setBalance(address account, uint256 amount) external {
        _burn(account, balanceOf(account));
        _mint(account, amount);
    }
}
