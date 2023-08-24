// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@forge-std/Test.sol";

import {ErrorsLib} from "contracts/oracles/libraries/ErrorsLib.sol";

import {BaseOracle} from "contracts/oracles/BaseOracle.sol";
import {NoopOracleMock} from "../mocks/NoopOracleMock.sol";

contract BaseOracleTest is Test {
    function testBaseOracle(uint256 scaleFactor) public {
        scaleFactor = bound(scaleFactor, 1, type(uint256).max);

        BaseOracle noopOracle = new NoopOracleMock(scaleFactor);
        assertEq(noopOracle.SCALE_FACTOR(), scaleFactor);
        assertEq(noopOracle.COLLATERAL_SCALE(), 0);
        assertEq(noopOracle.BORROWABLE_SCALE(), 0);
    }

    function testBaseOracleZeroScaleFactor() public {
        vm.expectRevert(bytes(ErrorsLib.ZERO_INPUT));
        new NoopOracleMock(0);
    }
}
