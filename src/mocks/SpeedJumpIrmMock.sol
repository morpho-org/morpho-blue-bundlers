// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {SpeedJumpIrm} from "@morpho-blue-irm/SpeedJumpIrm.sol";

uint256 constant LN2 = 0.69314718056 ether;
uint256 constant TARGET_UTILIZATION = 0.8 ether;
uint256 constant SPEED_FACTOR = uint256(0.01 ether) / uint256(10 hours);
uint128 constant INITIAL_RATE = uint128(0.01 ether) / uint128(365 days);

contract SpeedJumpIrmMock is SpeedJumpIrm {
    constructor(address morpho) SpeedJumpIrm(morpho, LN2, SPEED_FACTOR, TARGET_UTILIZATION, INITIAL_RATE) {}
}
