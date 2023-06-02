// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import {IPool} from "contracts/interfaces/IPool.sol";

import {Math} from "@morpho-utils/math/Math.sol";
import {PoolLib} from "contracts/libraries/PoolLib.sol";
import {BytesLib, POOL_OFFSET} from "contracts/libraries/BytesLib.sol";

import {BaseSupplyAllocator} from "contracts/BaseSupplyAllocator.sol";

contract SupplyGradientAllocator is BaseSupplyAllocator {
    using PoolLib for IPool;
    using BytesLib for bytes;

    constructor(address factory) BaseSupplyAllocator(factory) {}

    function allocateSupply(address asset, uint256 amount, bytes memory collateralization)
        external
        view
        returns (bytes memory allocation)
    {}

    function allocateWithdraw(address asset, uint256 amount, bytes memory collateralization)
        external
        view
        returns (bytes memory allocation)
    {}
}
