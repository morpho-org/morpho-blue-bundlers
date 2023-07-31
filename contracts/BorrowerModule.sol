// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.21;

import {Market, IBlue} from "@morpho-blue/interfaces/IBlue.sol";
import {IIrm} from "@morpho-blue/interfaces/IIrm.sol";
import {IERC20} from "@morpho-blue/interfaces/IERC20.sol";
import {IOracle} from "@morpho-blue/interfaces/IOracle.sol";

// This contract should be able to let borrowers delegate responbility to a third party to:
// 1. Move their position from an LLTV to a specified higher LLTV. (liquidation protection)
// 2. Move their position in an LLTV range (to optimize interest rates).

struct BorrowManagementParams {
    bool increaseLLtvAllowed;
    bool decreaseLltvAllowed;
    uint256 minLtv;
    uint256 maxLtv;
}

struct MarketNoLLTV {
    IERC20 borrowableAsset;
    IERC20 collateralAsset;
    IOracle borrowableOracle;
    IOracle collateralOracle;
    IIrm irm;
}
contract BorrowerModule {
    mapping(address borrower => mapping(address manager => mapping(bytes marketNoLltvId => BorrowManagementParams allowStruct))) internal _managementParams;

}

