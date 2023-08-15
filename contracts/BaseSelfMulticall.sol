// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.21;

import "@morpho-utils/DelegateCall.sol";

/// @title BaseSelfMulticall
/// @notice Enables calling multiple functions in a single call to the same contract (self).
abstract contract BaseSelfMulticall {
    using DelegateCall for address;

    /* INTERNAL */

    function _multicall(bytes[] memory data) internal returns (bytes[] memory results) {
        results = new bytes[](data.length);

        for (uint256 i; i < data.length; ++i) {
            results[i] = address(this).functionDelegateCall(data[i]);
        }
    }
}
