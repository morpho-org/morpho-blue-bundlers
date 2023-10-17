// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "../../WETHBundler.sol";
import "../../TransferBundler.sol";

contract WETHBundlerMock is TransferBundler, WETHBundler {
    constructor(address wEth) WETHBundler(wEth) {}
}
