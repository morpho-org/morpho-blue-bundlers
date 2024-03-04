// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "../../TransferBundler.sol";
import {MorphoBundlerV2} from "../../MorphoBundlerV2.sol";

contract MorphoBundlerV2Mock is TransferBundler, MorphoBundlerV2 {
    constructor(address morpho) MorphoBundlerV2(morpho) {}

    function _isSenderAuthorized() internal view override(BaseBundler, MorphoBundlerV2) returns (bool) {
        return MorphoBundlerV2._isSenderAuthorized();
    }
}
