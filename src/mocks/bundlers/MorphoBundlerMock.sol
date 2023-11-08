// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "../../TransferBundler.sol";
import "../../MorphoBundler.sol";

contract MorphoBundlerMock is TransferBundler, MorphoBundler {
    constructor(address morpho) MorphoBundler(morpho) {}

    function _isSenderAuthorized() internal view override(BaseBundler, MorphoBundler) returns (bool) {
        return MorphoBundler._isSenderAuthorized();
    }
}
