// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {BaseOracle} from "./BaseOracle.sol";
import {ErrorsLib} from "./libraries/ErrorsLib.sol";
import {IUniswapV3Pool, UniswapV3PoolLib} from "./libraries/UniswapV3PoolLib.sol";

contract UniswapV3Oracle is BaseOracle {
    using UniswapV3PoolLib for IUniswapV3Pool;

    // Constants.

    uint32 private immutable _COLLATERAL_WINDOW;
    bool private immutable _COLLATERAL_PRICE_INVERSED;
    uint32 private immutable _BORROWABLE_WINDOW;
    bool private immutable _BORROWABLE_PRICE_INVERSED;

    // Constructor.

    constructor(
        IUniswapV3Pool collateralPool,
        uint32 collateralWindow,
        address collateralQuoteToken,
        IUniswapV3Pool borrowablePool,
        uint32 borrowableWindow,
        address borrowableQuoteToken
    ) {
        COLLATERAL_FEED = address(collateralPool);
        _COLLATERAL_WINDOW = collateralWindow;
        _COLLATERAL_PRICE_INVERSED = _inversedPrice(collateralPool, collateralQuoteToken);

        BORROWABLE_FEED = address(borrowablePool);
        _BORROWABLE_WINDOW = borrowableWindow;
        _BORROWABLE_PRICE_INVERSED = _inversedPrice(borrowablePool, borrowableQuoteToken);
    }

    function _inversedPrice(IUniswapV3Pool pool, address quoteToken) internal returns (bool) {
        if (address(pool) != address(0)) {
            address token0 = pool.token0();
            address token1 = pool.token1();
            require(quoteToken == token0 || quoteToken == token1, ErrorsLib.INVALID_QUOTE_TOKEN);
            return quoteToken == token0;
        } else {
            return false;
        }
    }

    function _collateralPrice() internal view override returns (uint256) {
        if (COLLATERAL_FEED == address(0)) return 1;
        else return IUniswapV3Pool(COLLATERAL_FEED).priceX128(_COLLATERAL_WINDOW, _COLLATERAL_PRICE_INVERSED) * 1e36 / 1 << 128;
    }

    function _borrowablePrice() internal view override returns (uint256) {
        if (BORROWABLE_FEED == address(0)) return 1;
        else return IUniswapV3Pool(BORROWABLE_FEED).priceX128(_BORROWABLE_WINDOW, _BORROWABLE_PRICE_INVERSED) * 1e36 / 1 << 128;
    }
}
