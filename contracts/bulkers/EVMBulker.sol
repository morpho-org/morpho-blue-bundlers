// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.21;

import {MorphoBulker} from "./MorphoBulker.sol";
import {ERC20Bulker} from "./ERC20Bulker.sol";

/// @title EVMBulker.
/// @author Morpho Labs.
/// @custom:contact security@blue.xyz
/// @notice Common bulker layer guaranteeing it can be deployed to the same address on all EVM-compatible chains.
contract EVMBulker is ERC20Bulker, MorphoBulker {
    address private constant _MORPHO = address(1);

    constructor() MorphoBulker(_MORPHO) {}
}
