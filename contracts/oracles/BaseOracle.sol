// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {IOracle} from "./interfaces/IOracle.sol";
import {ErrorsLib} from "./libraries/ErrorsLib.sol";
import {FullMath} from "@uniswap/v3-core/libraries/FullMath.sol";

abstract contract BaseOracle is IOracle {
    using FullMath for uint256;

    /// @notice The oracle price's precision.
    uint256 internal immutable _PRICE_PRECISION = 1e36;

    /// @notice Borrowable token feed.
    address public immutable COLLATERAL_FEED;

    /// @notice Collateral token feed.
    address public immutable BORROWABLE_FEED;

    /// @notice Price.
    function price() external view returns (uint256) {
        // Using FullMath's 512 bit multiplication to avoid overflowing.
        return _PRICE_PRECISION.mulDiv(_collateralPrice(), _borrowablePrice());
    }

    /// @dev Price of one asset of collateral asset with `_PRICE_SCALE` of precision.
    function _collateralPrice() internal view virtual returns (uint256);
    
    /// @dev Price of one asset of borrowable asset with `_PRICE_SCALE` of precision.
    function _borrowablePrice() internal view virtual returns (uint256);
}
