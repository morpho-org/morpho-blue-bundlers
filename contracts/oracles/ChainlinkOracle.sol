// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {BaseOracle} from "./BaseOracle.sol";
import {ErrorsLib} from "./libraries/ErrorsLib.sol";
import {IChainlinkAggregatorV3} from "./interfaces/IChainlinkAggregatorV3.sol";
import {ChainlinkAggregatorV3Lib} from "./libraries/ChainlinkAggregatorV3Lib.sol";
import {IERC20Metadata as IERC20} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

contract ChainlinkOracle is BaseOracle {
    using ChainlinkAggregatorV3Lib for IChainlinkAggregatorV3;

    /// @dev Collateral token price precision.
    uint256 private immutable _COLLATERAL_PRICE_PRECISION;
    
    /// @dev Borrowable token price precision.
    uint256 private immutable _BORROWABLE_PRICE_PRECISION;

    /// @dev Collateral token decimals.
    uint256 private immutable _COLLATERAL_DECIMALS;

    /// @dev Borrowable token decimals.
    uint256 private immutable _BORROWABLE_DECIMALS;

    constructor(IChainlinkAggregatorV3 collateralFeed, IERC20 collateralToken, IChainlinkAggregatorV3 borrowableFeed, IERC20 borrowableToken) {
        COLLATERAL_FEED = address(collateralFeed);
        BORROWABLE_FEED = address(borrowableFeed);

        _COLLATERAL_PRICE_PRECISION = address(collateralFeed) != address(0) ? 10 ** collateralFeed.decimals() : 1;
        _BORROWABLE_PRICE_PRECISION = address(borrowableFeed) != address(0) ? 10 ** borrowableFeed.decimals() : 1;

        _COLLATERAL_DECIMALS = collateralToken.decimals();
        _BORROWABLE_DECIMALS = borrowableToken.decimals();
    }

    function _collateralPrice() internal view override returns (uint256) {
        if (COLLATERAL_FEED == address(0)) return 1;
        else return IChainlinkAggregatorV3(COLLATERAL_FEED).price() * _COLLATERAL_DECIMALS * _PRICE_PRECISION / _COLLATERAL_PRICE_PRECISION;
    }

    function _borrowablePrice() internal view override returns (uint256) {
        if (BORROWABLE_FEED == address(0)) return 1;
        else return IChainlinkAggregatorV3(BORROWABLE_FEED).price() * _BORROWABLE_DECIMALS * _PRICE_PRECISION / _BORROWABLE_PRICE_PRECISION;
    }
}
