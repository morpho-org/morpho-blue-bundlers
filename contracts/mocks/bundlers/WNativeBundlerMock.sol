// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "../../WNativeBundler.sol";

contract WNativeBundlerMock is WNativeBundler {
    constructor(address wNative) WNativeBundler(wNative) {}
}
