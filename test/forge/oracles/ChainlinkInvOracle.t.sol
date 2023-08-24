// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@forge-std/Test.sol";

import {IOracle} from "contracts/oracles/interfaces/IOracle.sol";

import {ErrorsLib} from "contracts/oracles/libraries/ErrorsLib.sol";
import {OracleFeed} from "contracts/oracles/libraries/OracleFeed.sol";
import {FullMath} from "@uniswap/v3-core/libraries/FullMath.sol";

import {ChainlinkOracle} from "contracts/oracles/ChainlinkInvOracle.sol";
import {ChainlinkAggregatorV3Mock} from "../mocks/ChainlinkAggregatorV3Mock.sol";

contract ChainlinkInvOracleTest is Test {
    using FullMath for uint256;

    ChainlinkAggregatorV3Mock borrowableFeed;

    function setUp() public {
        borrowableFeed = new ChainlinkAggregatorV3Mock("borrowable price");
    }

    function testZeroFeed(uint256 scaleFactor) public {
        scaleFactor = bound(scaleFactor, 1, type(uint256).max);

        vm.expectRevert(bytes(ErrorsLib.ZERO_ADDRESS));
        new ChainlinkOracle(scaleFactor, address(0));
    }

    function testZeroScaleFactor() public {
        vm.expectRevert(bytes(ErrorsLib.ZERO_INPUT));
        new ChainlinkOracle(0, address(borrowableFeed));
    }

    function testConfig(uint256 scaleFactor, uint8 decimals) public {
        scaleFactor = bound(scaleFactor, 1, type(uint256).max);
        decimals = uint8(bound(decimals, 0, 77));
        borrowableFeed.setDecimals(decimals);

        ChainlinkOracle oracle = new ChainlinkOracle(scaleFactor, address(borrowableFeed));

        (string memory collateralFeedLabel, address collateralFeedAddress) = oracle.COLLATERAL_FEED();
        assertEq(collateralFeedLabel, OracleFeed.STATIC);
        assertEq(collateralFeedAddress, address(0));
        assertEq(oracle.COLLATERAL_SCALE(), 1);

        (string memory borrowableFeedLabel, address borrowableFeedAddress) = oracle.BORROWABLE_FEED();
        assertEq(borrowableFeedLabel, OracleFeed.CHAINLINK_V3);
        assertEq(borrowableFeedAddress, address(borrowableFeed));
        assertEq(oracle.BORROWABLE_SCALE(), 10 ** uint256(borrowableFeed.decimals()));

        assertEq(oracle.SCALE_FACTOR(), scaleFactor);
    }

    function testNegativePrice(uint256 scaleFactor, uint8 decimals, int256 price) public {
        scaleFactor = bound(scaleFactor, 1, type(uint256).max);
        decimals = uint8(bound(decimals, 0, 77));
        price = bound(price, type(int256).min, 0);
        borrowableFeed.setDecimals(decimals);
        borrowableFeed.setAnswer(price);

        ChainlinkOracle oracle = new ChainlinkOracle(scaleFactor, address(borrowableFeed));

        assertEq(oracle.collateralPrice(), 1, "collateral price");

        vm.expectRevert();
        oracle.borrowablePrice();

        vm.expectRevert();
        oracle.price();
    }

    function testPrice(uint256 scaleFactor, uint8 decimals, int256 price) public {
        scaleFactor = bound(scaleFactor, 1, type(uint128).max);
        decimals = uint8(bound(decimals, 0, 77));
        price = bound(price, 1, type(int128).max);
        borrowableFeed.setDecimals(decimals);
        borrowableFeed.setAnswer(price);

        ChainlinkOracle oracle = new ChainlinkOracle(scaleFactor, address(borrowableFeed));

        assertEq(oracle.collateralPrice(), 1, "collateral price");
        assertEq(oracle.borrowablePrice(), uint256(price), "borrowable price");
        assertEq(oracle.price(), scaleFactor.mulDiv(10 ** decimals, uint256(price)), "price");
    }
}
