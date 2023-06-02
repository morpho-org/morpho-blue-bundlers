// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import {IPool} from "contracts/interfaces/IPool.sol";
import {ISupplyAllocator} from "contracts/interfaces/ISupplyAllocator.sol";

import {PoolAddress} from "contracts/libraries/PoolAddress.sol";

abstract contract BaseSupplyAllocator is ISupplyAllocator {
    address internal immutable FACTORY;

    constructor(address factory) {
        FACTORY = factory;
    }

    function getPool(address collateral, address asset) internal view returns (IPool) {
        return IPool(PoolAddress.computeAddress(FACTORY, collateral, asset));
    }
}
