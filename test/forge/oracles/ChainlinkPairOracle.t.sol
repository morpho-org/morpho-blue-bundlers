// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@forge-std/Test.sol";

import {IOracle} from "contracts/oracles/interfaces/IOracle.sol";

import {ErrorsLib} from "contracts/oracles/libraries/ErrorsLib.sol";
import {OracleFeed} from "contracts/oracles/libraries/OracleFeed.sol";
import {FullMath} from "@uniswap/v3-core/libraries/FullMath.sol";

import {ChainlinkPairOracle} from "contracts/oracles/ChainlinkPairOracle.sol";
import {ChainlinkAggregatorV3Mock} from "../mocks/ChainlinkAggregatorV3Mock.sol";

contract ChainlinkPairOracleTest is Test {
    using FullMath for uint256;

    ChainlinkAggregatorV3Mock collateralFeed;
    ChainlinkAggregatorV3Mock borrowableFeed;

    function setUp() public {
        collateralFeed = new ChainlinkAggregatorV3Mock("collateral price");
        borrowableFeed = new ChainlinkAggregatorV3Mock("borrowable price");
    }

    function testZeroCollateralFeed(uint256 scaleFactor) public {
        scaleFactor = bound(scaleFactor, 1, type(uint256).max);

        vm.expectRevert(bytes(ErrorsLib.ZERO_ADDRESS));
        new ChainlinkPairOracle(scaleFactor, address(0), address(borrowableFeed));
    }

    function testZeroBorrowableFeed(uint256 scaleFactor) public {
        scaleFactor = bound(scaleFactor, 1, type(uint256).max);

        vm.expectRevert(bytes(ErrorsLib.ZERO_ADDRESS));
        new ChainlinkPairOracle(scaleFactor, address(collateralFeed), address(0));
    }

    function testZeroScaleFactor() public {
        vm.expectRevert(bytes(ErrorsLib.ZERO_INPUT));
        new ChainlinkPairOracle(0, address(collateralFeed), address(borrowableFeed));
    }

    function testConfig(uint256 scaleFactor, uint8 collateralFeedDecimals, uint8 borrowableFeedDecimals) public {
        scaleFactor = bound(scaleFactor, 1, type(uint256).max);
        collateralFeedDecimals = uint8(bound(collateralFeedDecimals, 0, 77));
        borrowableFeedDecimals = uint8(bound(borrowableFeedDecimals, 0, 77));
        collateralFeed.setDecimals(collateralFeedDecimals);
        borrowableFeed.setDecimals(borrowableFeedDecimals);

        ChainlinkPairOracle oracle =
            new ChainlinkPairOracle(scaleFactor, address(collateralFeed), address(borrowableFeed));

        (string memory collateralFeedLabel, address collateralFeedAddress) = oracle.COLLATERAL_FEED();
        assertEq(collateralFeedLabel, OracleFeed.CHAINLINK_V3);
        assertEq(collateralFeedAddress, address(collateralFeed));
        assertEq(oracle.COLLATERAL_SCALE(), 10 ** uint256(collateralFeed.decimals()));

        (string memory borrowableFeedLabel, address borrowableFeedAddress) = oracle.BORROWABLE_FEED();
        assertEq(borrowableFeedLabel, OracleFeed.CHAINLINK_V3);
        assertEq(borrowableFeedAddress, address(borrowableFeed));
        assertEq(oracle.BORROWABLE_SCALE(), 10 ** uint256(borrowableFeed.decimals()));

        assertEq(oracle.SCALE_FACTOR(), scaleFactor);
    }

    function testNegativeCollateralPrice(
        uint256 scaleFactor,
        uint8 collateralFeedDecimals,
        uint8 borrowableFeedDecimals,
        int256 collateralPrice,
        int256 borrowablePrice
    ) public {
        scaleFactor = bound(scaleFactor, 1, type(uint256).max);
        collateralFeedDecimals = uint8(bound(collateralFeedDecimals, 0, 77));
        borrowableFeedDecimals = uint8(bound(borrowableFeedDecimals, 0, 77));
        collateralPrice = bound(collateralPrice, type(int256).min, 0);
        collateralFeed.setDecimals(collateralFeedDecimals);
        borrowableFeed.setDecimals(borrowableFeedDecimals);
        collateralFeed.setAnswer(collateralPrice);
        borrowableFeed.setAnswer(borrowablePrice);

        ChainlinkPairOracle oracle =
            new ChainlinkPairOracle(scaleFactor, address(collateralFeed), address(borrowableFeed));

        vm.expectRevert();
        oracle.collateralPrice();

        vm.expectRevert();
        oracle.price();
    }

    function testNegativeBorrowablePrice(
        uint256 scaleFactor,
        uint8 collateralFeedDecimals,
        uint8 borrowableFeedDecimals,
        int256 collateralPrice,
        int256 borrowablePrice
    ) public {
        scaleFactor = bound(scaleFactor, 1, type(uint256).max);
        collateralFeedDecimals = uint8(bound(collateralFeedDecimals, 0, 77));
        borrowableFeedDecimals = uint8(bound(borrowableFeedDecimals, 0, 77));
        borrowablePrice = bound(borrowablePrice, type(int256).min, 0);
        collateralFeed.setDecimals(collateralFeedDecimals);
        borrowableFeed.setDecimals(borrowableFeedDecimals);
        collateralFeed.setAnswer(collateralPrice);
        borrowableFeed.setAnswer(borrowablePrice);

        ChainlinkPairOracle oracle =
            new ChainlinkPairOracle(scaleFactor, address(collateralFeed), address(borrowableFeed));

        vm.expectRevert();
        oracle.borrowablePrice();

        vm.expectRevert();
        oracle.price();
    }

    function testPrice(
        uint256 scaleFactor,
        uint8 collateralFeedDecimals,
        uint8 borrowableFeedDecimals,
        int256 collateralPrice,
        int256 borrowablePrice
    ) public {
        scaleFactor = bound(scaleFactor, 1, type(uint120).max);
        collateralFeedDecimals = uint8(bound(collateralFeedDecimals, 0, 34));
        borrowableFeedDecimals = uint8(bound(borrowableFeedDecimals, 0, 34));
        collateralPrice = bound(collateralPrice, 1, int256(10 ** (35 - collateralFeedDecimals)));
        borrowablePrice = bound(borrowablePrice, 1, int256(10 ** (35 - borrowableFeedDecimals)));
        collateralFeed.setDecimals(collateralFeedDecimals);
        borrowableFeed.setDecimals(borrowableFeedDecimals);
        collateralFeed.setAnswer(collateralPrice);
        borrowableFeed.setAnswer(borrowablePrice);

        ChainlinkPairOracle oracle =
            new ChainlinkPairOracle(scaleFactor, address(collateralFeed), address(borrowableFeed));

        assertEq(oracle.collateralPrice(), uint256(collateralPrice));
        assertEq(oracle.borrowablePrice(), uint256(borrowablePrice));

        uint256 collateralPriceInBorrowable =
            uint256(collateralPrice).mulDiv(10 ** borrowableFeedDecimals, uint256(borrowablePrice));
        assertEq(oracle.price(), scaleFactor.mulDiv(collateralPriceInBorrowable, 10 ** collateralFeedDecimals));
    }
}
