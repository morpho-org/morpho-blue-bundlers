// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {IChainlinkAggregatorV3} from "../adapters/interfaces/IChainlinkAggregatorV3.sol";

library ChainlinkAggregatorV3Lib {
    function price(IChainlinkAggregatorV3 aggregator) internal view returns (uint256) {
        (, int256 answer,,,) = aggregator.latestRoundData();
        if (answer < 0) return 0;
        return uint256(answer);
    }
}
