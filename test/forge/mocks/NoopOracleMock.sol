// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {BaseOracle} from "contracts/oracles/BaseOracle.sol";

contract NoopOracleMock is BaseOracle {
    constructor(uint256 scaleFactor) BaseOracle(scaleFactor) {}

    function collateralPrice() public pure override returns (uint256) {
        return 0;
    }

    function borrowablePrice() public pure override returns (uint256) {
        return 0;
    }

    function BORROWABLE_FEED() external view returns (string memory, address) {
        return ("noop", address(this));
    }

    function COLLATERAL_FEED() external view returns (string memory, address) {
        return ("noop", address(this));
    }
}
