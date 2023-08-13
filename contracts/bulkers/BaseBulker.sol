// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.21;

import {Errors} from "./libraries/Errors.sol";

import {IMulticall} from "./interfaces/IMulticall.sol";

import {SelfMulticall} from "./SelfMulticall.sol";

/// @title BaseBulker.
/// @author Morpho Labs.
/// @custom:contact security@blue.xyz
abstract contract BaseBulker is SelfMulticall {
    /* EXTERNAL */

    function callBulker(address bulker, bytes[] calldata data) external {
        require(bulker != address(0), Errors.ZERO_ADDRESS);

        IMulticall(bulker).multicall(block.timestamp, data);
    }
}
