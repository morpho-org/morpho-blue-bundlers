// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {IChainlinkAggregatorV3} from "contracts/oracles/adapters/interfaces/IChainlinkAggregatorV3.sol";

import {ChainlinkAggregatorV3Lib} from "contracts/oracles/libraries/ChainlinkAggregatorV3Lib.sol";

contract ChainlinkAggregatorV3LibMock {
    using ChainlinkAggregatorV3Lib for IChainlinkAggregatorV3;

    function price(IChainlinkAggregatorV3 priceFeed) external view returns (uint256) {
        return priceFeed.price();
    }

    function price(IChainlinkAggregatorV3 priceFeed, IChainlinkAggregatorV3 sequencerUptimeFeed, uint256 gracePeriod)
        external
        view
        returns (uint256)
    {
        return priceFeed.price(sequencerUptimeFeed, gracePeriod);
    }
}
