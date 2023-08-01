// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.21;

import {MarketLib, Id, Market} from "@morpho-blue/libraries/MarketLib.sol";
import {IBlue} from "@morpho-blue/interfaces/IBlue.sol";
import {IBlueRepayCallback} from "@morpho-blue/interfaces/IBlueCallbacks.sol";
import {IIrm} from "@morpho-blue/interfaces/IIrm.sol";
import {IERC20} from "@morpho-blue/interfaces/IERC20.sol";
import {IOracle} from "@morpho-blue/interfaces/IOracle.sol";

// This contract should be able to let borrowers delegate responbility to a third party to:
// 1. Move their position from an LLTV to a specified higher LLTV. (liquidation protection)
// 2. Move their position in an LLTV range (to optimize interest rates).

struct BorrowManagementParams {
    bool increaseLltvAllowed;
    bool decreaseLltvAllowed;
    uint256 minLltv;
    uint256 maxLltv;
}

struct MarketNoLLTV {
    IERC20 borrowableAsset;
    IERC20 collateralAsset;
    IOracle borrowableOracle;
    IOracle collateralOracle;
    IIrm irm;
}

contract BorrowerModule is IBlueRepayCallback {
    using MarketLib for Market;

    IBlue public immutable blue;

    mapping(
        address borrower
            => mapping(address manager => mapping(bytes marketNoLltvId => BorrowManagementParams allowStruct))
    ) public managementParams;

    constructor(address newBlue) {
        blue = IBlue(newBlue);
    }

    function marketNoLltvToBytes(MarketNoLLTV memory marketNoLltv) internal pure returns (bytes memory) {
        return abi.encode(marketNoLltv);
    }

    function bytesToMarketNoLltv(bytes memory marketNoLltvBytes) internal pure returns (MarketNoLLTV memory) {
        return abi.decode(marketNoLltvBytes, (MarketNoLLTV));
    }

    function setIncreaseLltvAllowed(MarketNoLLTV memory marketNoLltv, address manager, bool allowed) external {
        managementParams[msg.sender][manager][marketNoLltvToBytes(marketNoLltv)].increaseLltvAllowed = allowed;
    }

    function setDecreaseLltvAllowed(MarketNoLLTV memory marketNoLltv, address manager, bool allowed) external {
        managementParams[msg.sender][manager][marketNoLltvToBytes(marketNoLltv)].decreaseLltvAllowed = allowed;
    }

    function setMinLtv(MarketNoLLTV memory marketNoLltv, address manager, uint256 minLltv) external {
        managementParams[msg.sender][manager][marketNoLltvToBytes(marketNoLltv)].minLltv = minLltv;
    }

    function setMaxLtv(MarketNoLLTV memory marketNoLltv, address manager, uint256 maxLltv) external {
        managementParams[msg.sender][manager][marketNoLltvToBytes(marketNoLltv)].maxLltv = maxLltv;
    }

    function moveLltv(Market memory market, address borrower, uint256 newLltv) external {
        MarketNoLLTV memory marketNoLLTV = MarketNoLLTV({
            borrowableAsset: market.borrowableAsset,
            collateralAsset: market.collateralAsset,
            borrowableOracle: market.borrowableOracle,
            collateralOracle: market.collateralOracle,
            irm: market.irm
        });
        BorrowManagementParams storage params =
            managementParams[borrower][msg.sender][marketNoLltvToBytes(marketNoLLTV)];
        require(newLltv != market.lltv, "BorrowerModule: newLltv is the same as current lltv");
        if (newLltv > market.lltv) {
            require(params.increaseLltvAllowed && newLltv <= params.maxLltv, "BorrowerModule: increaseLltv not allowed");
        } else {
            require(params.decreaseLltvAllowed && newLltv >= params.minLltv, "BorrowerModule: decreaseLltv not allowed");
        }

        _moveLltv(market, borrower, newLltv);
    }

    function _moveLltv(Market memory market, address borrower, uint256 newLltv) internal {
        // Repay all debt in old market.
        blue.repay(market, type(uint256).max, borrower, abi.encode(market, borrower, newLltv));
        // Logic continues in the callback function onBlueRepay.
    }

    function onBlueRepay(uint256 amount, bytes calldata data) external override {
        require(msg.sender == address(blue), "BorrowerModule: invalid caller");
        (Market memory market, address borrower, uint256 newLltv) = abi.decode(data, (Market, address, uint256));
        // After a repay:
        // Withdraw all collateral in old market.
        uint256 collateral = blue.collateral(market.id(), borrower);
        blue.withdrawCollateral(market, collateral, borrower);

        // Change context to new market.
        market.lltv = newLltv;

        // Deposit all collateral in new market.
        blue.supplyCollateral(market, collateral, borrower, hex"");
        // Borrow all debt in new market.
        blue.borrow(market, amount, borrower);

        // After this call, blue should retrieve the borrowed funds.
    }
}
