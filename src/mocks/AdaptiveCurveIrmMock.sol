// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {AdaptiveCurveIrm} from "../../lib/morpho-blue-irm/src/adaptive-curve-irm/AdaptiveCurveIrm.sol";

contract AdaptiveCurveIrmMock is AdaptiveCurveIrm {
    constructor(address morpho) AdaptiveCurveIrm(morpho) {}
}
