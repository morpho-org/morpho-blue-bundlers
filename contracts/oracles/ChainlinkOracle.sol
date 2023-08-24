// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {BaseOracle} from "./BaseOracle.sol";
import {ErrorsLib} from "./libraries/ErrorsLib.sol";
import {IChainlinkAggregatorV3} from "./interfaces/IChainlinkAggregatorV3.sol";
import {ChainlinkAggregatorV3Lib} from "./libraries/ChainlinkAggregatorV3Lib.sol";

contract ChainlinkOracle is BaseOracle {
    using ChainlinkAggregatorV3Lib for IChainlinkAggregatorV3;

    /// @dev The collateral price's scale.
    uint256 private immutable _COLLATERAL_PRICE_SCALE;
    
    /// @dev The borrowable price's scale.
    uint256 private immutable _BORROWABLE_PRICE_SCALE;

    constructor(IChainlinkAggregatorV3 collateralFeed, IChainlinkAggregatorV3 borrowableFeed) {
        COLLATERAL_FEED = address(collateralFeed);
        BORROWABLE_FEED = address(borrowableFeed);

        _COLLATERAL_PRICE_SCALE = address(collateralFeed) != address(0) ? 10 ** collateralFeed.decimals() : 1;
        _BORROWABLE_PRICE_SCALE = address(borrowableFeed) != address(0) ? 10 ** borrowableFeed.decimals() : 1;
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
