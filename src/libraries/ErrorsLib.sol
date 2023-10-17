// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

/// @title ErrorsLib
/// @author Morpho Labs
/// @custom:contact security@morpho.org
/// @notice Library exposing error messages.
library ErrorsLib {
    /* STANDARD BUNDLERS */

    /// @dev Thrown when a call is attempted while the bundler is not in an initiated execution context.
    string internal constant UNINITIATED = "uninitiated";

    /// @dev Thrown when a call is attempted with a zero address as input.
    string internal constant ZERO_ADDRESS = "zero address";

    /// @dev Thrown when a call is attempted with the bundler address as input.
    string internal constant BUNDLER_ADDRESS = "bundler address";

    /// @dev Thrown when a call is attempted with a zero amount as input.
    string internal constant ZERO_AMOUNT = "zero amount";

    /// @dev Thrown when a call is attempted with a zero shares as input.
    string internal constant ZERO_SHARES = "zero shares";

    /// @dev Thrown when only the wrapped native token can send ETH to the contract.
    string internal constant ONLY_WETH = "only weth";

    /// @dev Thrown when a call reverted and wasn't allowed to revert.
    string internal constant CALL_FAILED = "call failed";

    /* MIGRATION BUNDLERS */

    /// @dev Thrown when a redeem on Compound V2 failed.
    string internal constant REDEEM_ERROR = "redeem error";

    /// @dev Thrown when a repay on Compound V2 failed.
    string internal constant REPAY_ERROR = "repay error";

    /// @dev Thrown when only a the wrapped native token or the native cToken can send ETH to the migration bundler.
    string internal constant UNAUTHORIZED_SENDER = "unauthorized sender";
}
