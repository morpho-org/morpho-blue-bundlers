// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

/// @title ErrorsLib
/// @author Morpho Labs
/// @custom:contact security@morpho.xyz
/// @notice Library exposing error messages.
library ErrorsLib {
    /// @dev Thrown when a redeem on Compound V2 failed.
    string internal constant REDEEM_ERROR = "redeem error";

    /// @dev Thrown when a repay on Compound V2 failed.
    string internal constant REPAY_ERROR = "repay error";

    /// @dev Thrown when only a the wrapped native token or the native cToken can send ETH to the migration bundler.
    string internal constant UNAUTHORIZED_SENDER = "unauthorized sender";
}
