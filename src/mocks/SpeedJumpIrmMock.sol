// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {SpeedJumpIrm} from "../../lib/morpho-blue-irm/src/SpeedJumpIrm.sol";

uint256 constant _LN2 = 0.69314718056 ether;
uint256 constant _TARGET_UTILIZATION = 0.8 ether;
uint256 constant _SPEED_FACTOR = uint256(0.01 ether) / uint256(10 hours);
uint128 constant _INITIAL_RATE = uint128(0.01 ether) / uint128(365 days);

contract SpeedJumpIrmMock is SpeedJumpIrm {
    constructor(address morpho) SpeedJumpIrm(morpho, _LN2, _SPEED_FACTOR, _TARGET_UTILIZATION, _INITIAL_RATE) {}
}
