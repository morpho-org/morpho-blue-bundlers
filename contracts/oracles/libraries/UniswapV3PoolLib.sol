// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {ERC20} from "@solmate/tokens/ERC20.sol";

import {FullMath} from "@uniswap/v3-core/libraries/FullMath.sol";
import {TickMath} from "@uniswap/v3-core/libraries/TickMath.sol";
import {IUniswapV3Pool} from "@uniswap/v3-core/interfaces/IUniswapV3Pool.sol";

/// @title UniswapV3PoolLib
/// @notice Provides functions to integrate with a V3 pool, as an oracle.
library UniswapV3PoolLib {
    /// @notice Calculates time-weighted means of tick for a given Uniswap V3 pool.
    /// @param pool Address of the pool that we want to observe.
    /// @param secondsAgo Number of seconds in the past from which to calculate the time-weighted means.
    /// @return arithmeticMeanTick The arithmetic mean tick from (block.timestamp - secondsAgo) to block.timestamp.
    function getArithmeticMeanTick(IUniswapV3Pool pool, uint32 secondsAgo)
        internal
        view
        returns (int24 arithmeticMeanTick)
    {
        uint32[] memory secondsAgos = new uint32[](2);
        secondsAgos[0] = secondsAgo;
        secondsAgos[1] = 0;

        (int56[] memory tickCumulatives,) = pool.observe(secondsAgos);

        int56 tickCumulativesDelta = tickCumulatives[1] - tickCumulatives[0];

        arithmeticMeanTick = int24(tickCumulativesDelta / int56(uint56(secondsAgo)));
        // Always round to negative infinity.
        if (tickCumulativesDelta < 0 && (tickCumulativesDelta % int56(uint56(secondsAgo)) != 0)) arithmeticMeanTick--;
    }

    /// @notice Given a tick and a token amount, calculates the amount of token received in exchange.
    /// @param tick Tick value used to calculate the quote.
    /// @param baseToken Address of an ERC20 token contract used as the baseAmount denomination.
    /// @param quoteToken Address of an ERC20 token contract used as the quoteAmount denomination.
    /// @return quoteAmount Amount of quoteToken received for baseAmount of baseToken.
    function getQuoteAtTick(int24 tick, address baseToken, address quoteToken)
        internal
        view
        returns (uint256 quoteAmount)
    {
        uint160 sqrtRatioX96 = TickMath.getSqrtRatioAtTick(tick);
        uint256 baseAmount = 10 ** ERC20(baseToken).decimals(); // Take a baseAmount of 1 token.

        // Calculate quoteAmount with better precision if it doesn't overflow when multiplied by itself
        if (sqrtRatioX96 <= type(uint128).max) {
            uint256 ratioX192 = uint256(sqrtRatioX96) * sqrtRatioX96;

            quoteAmount = baseToken < quoteToken
                ? FullMath.mulDiv(ratioX192, baseAmount, 1 << 192)
                : FullMath.mulDiv(1 << 192, baseAmount, ratioX192);
        } else {
            uint256 ratioX128 = FullMath.mulDiv(sqrtRatioX96, sqrtRatioX96, 1 << 64);

            quoteAmount = baseToken < quoteToken
                ? FullMath.mulDiv(ratioX128, baseAmount, 1 << 128)
                : FullMath.mulDiv(1 << 128, baseAmount, ratioX128);
        }
    }

    function price(IUniswapV3Pool pool, uint32 secondsAgo, address baseToken, address quoteToken)
        internal
        view
        returns (uint256)
    {
        int24 arithmeticMeanTick = getArithmeticMeanTick(pool, secondsAgo);
        return getQuoteAtTick(arithmeticMeanTick, baseToken, quoteToken);
    }
}
