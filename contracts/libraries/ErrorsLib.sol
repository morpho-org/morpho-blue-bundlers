// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

/// @title ErrorsLib
/// @author Morpho Labs
/// @custom:contact security@morpho.xyz
/// @notice Library exposing error messages.
library ErrorsLib {
    /// @dev Thrown when a call is attempted while the bundler is not in an initiated execution context.
    string internal constant UNINITIATED = "uninitiated";

    /// @dev Thrown when a call is attempted while the deadline is expired.
    string internal constant DEADLINE_EXPIRED = "deadline expired";

    /// @dev Thrown when a call is attempted with a zero address as input.
    string internal constant ZERO_ADDRESS = "zero address";

    /// @dev Thrown when a call is attempted with the bundler address as input.
    string internal constant BUNDLER_ADDRESS = "bundler address";

    /// @dev Thrown when a call is attempted with a zero amount as input.
    string internal constant ZERO_AMOUNT = "zero amount";

    /// @dev Thrown when a call is attempted with a zero shares as input.
    string internal constant ZERO_SHARES = "zero shares";

    /// @dev Thrown when only the wrapped native token can send ETH to the contract.
    string internal constant ONLY_WNATIVE = "only wrapped native";
}
