// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {IUniswapV3Pool} from "@uniswap/v3-core/interfaces/IUniswapV3Pool.sol";

abstract contract UniswapV3CollateralAdapter {
    IUniswapV3Pool public immutable UNI_V3_COLLATERAL_POOL;
    uint32 public immutable UNI_V3_COLLATERAL_DELAY;
    address public immutable COLLATERAL_TOKEN;
    address public immutable COLLATERAL_QUOTE_TOKEN;

    constructor(address pool, uint32 delay, address collateralToken, address quoteToken) {
        UNI_V3_COLLATERAL_POOL = IUniswapV3Pool(pool);
        UNI_V3_COLLATERAL_DELAY = delay;
        COLLATERAL_TOKEN = collateralToken;
        COLLATERAL_QUOTE_TOKEN = quoteToken;
    }
}
