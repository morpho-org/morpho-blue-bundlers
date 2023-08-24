// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.5.0;

import {IOracle as IBlueOracle} from "@morpho-blue/interfaces/IOracle.sol";

interface IOracle is IBlueOracle {
    function COLLATERAL_FEED() external view returns (address);
    function BORROWABLE_FEED() external view returns (address);
}
