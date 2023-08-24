// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {IOracle} from "./interfaces/IOracle.sol";
import {ErrorsLib} from "./libraries/ErrorsLib.sol";
import {FullMath} from "@uniswap/v3-core/libraries/FullMath.sol";

abstract contract BaseOracle is IOracle {
    using FullMath for uint256;

    /// @notice The oracle price's scale.
    /// @dev The oracle must return the price of 1 asset of collateral token quoted in 1 asset of borrowable token,
    /// scaled by 1e36.
    /// @dev It corresponds to the price of 10**(collateral decimals) assets of collateral token quoted in
    /// 10**(borrowable decimals) assets of borrowable token with `36 + borrowable decimals - collateral decimals`
    /// decimals of precision.
    uint256 internal immutable _PRICE_SCALE = 36;

    /// @notice The collateral price's scale.
    uint256 internal immutable _COLLATERAL_PRICE_SCALE;

    /// @notice The borrowable price's scale.
    uint256 internal immutable _BORROWABLE_PRICE_SCALE;

    /// @notice Borrowable token feed.
    address public immutable COLLATERAL_FEED;

    /// @notice Collateral token feed.
    address public immutable BORROWABLE_FEED;

    function price() external view returns (uint256) {
        // Using FullMath's 512 bit multiplication to avoid overflowing.
        uint256 invBorrowablePrice = _PRICE_SCALE.mulDiv(_BORROWABLE_PRICE_SCALE, _borrowablePrice());

        return _collateralPrice().mulDiv(invBorrowablePrice, _COLLATERAL_PRICE_SCALE);
    }

    function _collateralPrice() internal view virtual returns (uint256);
    function _borrowablePrice() internal view virtual returns (uint256);
}
