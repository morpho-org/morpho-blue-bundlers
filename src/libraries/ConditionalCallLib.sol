// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {Address} from "@openzeppelin/utils/Address.sol";

library ConditionalCallLib {
    function conditionalCall(address target, bytes memory data, bool allowRevert)
        internal
        returns (bool callSuccess, bytes memory returnData)
    {
        (bool success, bytes memory returndata) = target.call(data);
        if (!allowRevert) {
            Address.verifyCallResultFromTarget(target, success, returndata, "Address: low-level call failed");
        }
    }
}
