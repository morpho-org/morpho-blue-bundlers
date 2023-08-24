// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@forge-std/Test.sol";

import {IOracle} from "contracts/oracles/interfaces/IOracle.sol";

import {ErrorsLib} from "contracts/oracles/libraries/ErrorsLib.sol";
import {OracleFeed} from "contracts/oracles/libraries/OracleFeed.sol";
import {FullMath} from "@uniswap/v3-core/libraries/FullMath.sol";

import {ChainlinkOracle} from "contracts/oracles/ChainlinkOracle.sol";
import {ChainlinkAggregatorV3Mock} from "../mocks/ChainlinkAggregatorV3Mock.sol";

contract ChainlinkOracleTest is Test {
    using FullMath for uint256;

    ChainlinkAggregatorV3Mock collateralFeed;

    function setUp() public {
        collateralFeed = new ChainlinkAggregatorV3Mock("collateral price");
    }

    function testZeroFeed(uint256 scaleFactor) public {
        scaleFactor = bound(scaleFactor, 1, type(uint256).max);

        vm.expectRevert(bytes(ErrorsLib.ZERO_ADDRESS));
        new ChainlinkOracle(scaleFactor, address(0));
    }

    function testZeroScaleFactor() public {
        vm.expectRevert(bytes(ErrorsLib.ZERO_INPUT));
        new ChainlinkOracle(0, address(collateralFeed));
    }

    function testConfig(uint256 scaleFactor, uint8 decimals) public {
        scaleFactor = bound(scaleFactor, 1, type(uint256).max);
        decimals = uint8(bound(decimals, 0, 77));
        collateralFeed.setDecimals(decimals);

        ChainlinkOracle oracle = new ChainlinkOracle(scaleFactor, address(collateralFeed));

        (string memory collateralFeedLabel, address collateralFeedAddress) = oracle.COLLATERAL_FEED();
        assertEq(collateralFeedLabel, OracleFeed.CHAINLINK_V3);
        assertEq(collateralFeedAddress, address(collateralFeed));
        assertEq(oracle.COLLATERAL_SCALE(), 10 ** uint256(collateralFeed.decimals()));

        (string memory borrowableFeedLabel, address borrowableFeedAddress) = oracle.BORROWABLE_FEED();
        assertEq(borrowableFeedLabel, OracleFeed.STATIC);
        assertEq(borrowableFeedAddress, address(0));
        assertEq(oracle.BORROWABLE_SCALE(), 1);

        assertEq(oracle.SCALE_FACTOR(), scaleFactor);
    }

    function testNegativePrice(uint256 scaleFactor, uint8 decimals, int256 price) public {
        scaleFactor = bound(scaleFactor, 1, type(uint256).max);
        decimals = uint8(bound(decimals, 0, 77));
        price = bound(price, type(int256).min, 0);
        collateralFeed.setDecimals(decimals);
        collateralFeed.setAnswer(price);

        ChainlinkOracle oracle = new ChainlinkOracle(scaleFactor, address(collateralFeed));

        assertEq(oracle.borrowablePrice(), 1);

        vm.expectRevert();
        oracle.collateralPrice();

        vm.expectRevert();
        oracle.price();
    }

    function testPrice(uint256 scaleFactor, uint8 decimals, int256 price) public {
        scaleFactor = bound(scaleFactor, 1, type(uint128).max);
        decimals = uint8(bound(decimals, 0, 77));
        price = bound(price, 1, type(int128).max);
        collateralFeed.setDecimals(decimals);
        collateralFeed.setAnswer(price);

        ChainlinkOracle oracle = new ChainlinkOracle(scaleFactor, address(collateralFeed));

        assertEq(oracle.borrowablePrice(), 1);
        assertEq(oracle.collateralPrice(), uint256(price));
        assertEq(oracle.price(), uint256(price).mulDiv(scaleFactor, 10 ** decimals));
    }
}
