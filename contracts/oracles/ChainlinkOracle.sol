// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {BaseOracle} from "./BaseOracle.sol";
import {ErrorsLib} from "./libraries/ErrorsLib.sol";
import {IChainlinkAggregatorV3} from "./interfaces/IChainlinkAggregatorV3.sol";
import {ChainlinkAggregatorV3Lib} from "./libraries/ChainlinkAggregatorV3Lib.sol";

contract ChainlinkOracle is BaseOracle {
    using ChainlinkAggregatorV3Lib for IChainlinkAggregatorV3;

    constructor(IChainlinkAggregatorV3 collateralFeed, IChainlinkAggregatorV3 borrowableFeed) {
        require(address(collateralFeed) != address(0), ErrorsLib.ZERO_ADDRESS);
        require(address(borrowableFeed) != address(0), ErrorsLib.ZERO_ADDRESS);

        COLLATERAL_FEED = address(collateralFeed);
        BORROWABLE_FEED = address(borrowableFeed);

        _COLLATERAL_PRICE_SCALE = 10 ** collateralFeed.decimals();
        _BORROWABLE_PRICE_SCALE = 10 ** borrowableFeed.decimals();
    }

    function _collateralPrice() internal view override returns (uint256) {
        if (COLLATERAL_FEED == address(0)) return 1;
        else return IChainlinkAggregatorV3(COLLATERAL_FEED).price();
    }

    function _borrowablePrice() internal view override returns (uint256) {
        if (BORROWABLE_FEED == address(0)) return 1;
        else return IChainlinkAggregatorV3(BORROWABLE_FEED).price();
    }
}
