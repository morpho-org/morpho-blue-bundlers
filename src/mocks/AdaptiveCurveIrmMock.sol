// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {AdaptiveCurveIrm} from "../../lib/morpho-blue-irm/src/AdaptiveCurveIrm.sol";

int256 constant _CURVE_STEEPNESS = 4 ether;
int256 constant _ADJUSTMENT_SPEED = int256(50 ether) / 365 days;
int256 constant _TARGET_UTILIZATION = 0.9 ether;
int256 constant _INITIAL_RATE_AT_TARGET = int256(0.01 ether) / 365 days;

contract AdaptiveCurveIrmMock is AdaptiveCurveIrm {
    constructor(address morpho)
        AdaptiveCurveIrm(morpho, _CURVE_STEEPNESS, _ADJUSTMENT_SPEED, _TARGET_UTILIZATION, _INITIAL_RATE_AT_TARGET)
    {}
}
