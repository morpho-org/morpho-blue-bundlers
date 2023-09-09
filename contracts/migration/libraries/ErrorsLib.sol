// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

/// @title ErrorsLib
/// @author Morpho Labs
/// @custom:contact security@morpho.xyz
/// @notice Library exposing error messages.
library ErrorsLib {
    string internal constant REDEEM_ERROR = "redeem error";

    string internal constant REPAY_ERROR = "repay error";

    string internal constant UNAUTHORIZED_SENDER = "unauthorized sender";
}
