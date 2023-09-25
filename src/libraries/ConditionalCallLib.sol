// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {Address} from "@openzeppelin/utils/Address.sol";

/// @title ConditionalCallLib
/// @author Morpho Labs
/// @custom:contact security@morpho.org
/// @notice Library allowing to perform calls while allowing or not reverts.
library ConditionalCallLib {
    /// @notice Calls the given `target` with `data` and reverts if `allowRevert` is false and the call reverts.
    function conditionalCall(address target, bytes memory data, bool allowRevert) internal {
        (bool success, bytes memory returndata) = target.call(data);

        if (!allowRevert) {
            Address.verifyCallResultFromTarget(target, success, returndata, "Address: low-level call failed");
        }
    }
}
