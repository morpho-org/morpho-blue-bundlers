// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@forge-std/Test.sol";

import {IChainlinkAggregatorV3} from "contracts/oracles/adapters/interfaces/IChainlinkAggregatorV3.sol";

import {ChainlinkAggregatorV3LibMock} from "../mocks/ChainlinkAggregatorV3LibMock.sol";
import {ChainlinkAggregatorV3Mock} from "../mocks/ChainlinkAggregatorV3Mock.sol";

contract ChainlinkAggregatorV3LibTest is Test {
    ChainlinkAggregatorV3LibMock mockLib;
    ChainlinkAggregatorV3Mock priceFeed;
    ChainlinkAggregatorV3Mock sequencerUptimeFeed;

    function setUp() public {
        priceFeed = new ChainlinkAggregatorV3Mock("price feed");
        sequencerUptimeFeed = new ChainlinkAggregatorV3Mock("sequencer uptime feed");
        mockLib = new ChainlinkAggregatorV3LibMock();
    }

    function testChainlinkAggregatorV3LibNegativePrice(int256 price) public {
        price = bound(price, type(int256).min, 0);
        priceFeed.setAnswer(price);

        vm.expectRevert();
        mockLib.price(IChainlinkAggregatorV3(priceFeed));
    }

    function testChainlinkAggregatorV3Lib(int256 price) public {
        price = bound(price, 1, type(int256).max);
        priceFeed.setAnswer(price);

        assertEq(mockLib.price(IChainlinkAggregatorV3(priceFeed)), uint256(price));
    }

    function testChainlinkAggregatorV3LibSequencerDown(int256 price, uint256 gracePeriod) public {
        price = bound(price, type(int256).min, 0);
        priceFeed.setAnswer(price);
        sequencerUptimeFeed.setAnswer(1); // sequencer is down

        vm.expectRevert();
        mockLib.price(IChainlinkAggregatorV3(priceFeed), IChainlinkAggregatorV3(sequencerUptimeFeed), gracePeriod);
    }

    function testChainlinkAggregatorV3LibGracePeriodNotOver(
        int256 price,
        uint256 timestamp,
        uint128 startedAt,
        uint128 gracePeriod
    ) public {
        timestamp = bound(timestamp, startedAt, uint256(startedAt) + uint256(gracePeriod));
        vm.warp(timestamp);

        price = bound(price, 1, type(int256).max);
        priceFeed.setAnswer(price);
        sequencerUptimeFeed.setAnswer(0); // sequencer is up
        sequencerUptimeFeed.setStartedAt(startedAt);

        vm.expectRevert();
        mockLib.price(IChainlinkAggregatorV3(priceFeed), IChainlinkAggregatorV3(sequencerUptimeFeed), gracePeriod);
    }

    function testChainlinkAggregatorV3LibSequencerUp(
        int256 price,
        uint256 timestamp,
        uint128 startedAt,
        uint128 gracePeriod
    ) public {
        timestamp = bound(timestamp, uint256(startedAt) + uint256(gracePeriod) + 1, type(uint256).max);
        vm.warp(timestamp);

        price = bound(price, 1, type(int256).max);
        priceFeed.setAnswer(price);
        sequencerUptimeFeed.setAnswer(0); // sequencer is up
        sequencerUptimeFeed.setStartedAt(startedAt);

        assertEq(
            mockLib.price(IChainlinkAggregatorV3(priceFeed), IChainlinkAggregatorV3(sequencerUptimeFeed), gracePeriod),
            uint256(price)
        );
    }
}
