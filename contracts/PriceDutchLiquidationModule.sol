// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.21;

import {MarketLib, Id, Market} from "@morpho-blue/libraries/MarketLib.sol";
import {SharesMath} from "@morpho-blue/libraries/SharesMath.sol";
import {IBlue} from "@morpho-blue/interfaces/IBlue.sol";
import {IBlueRepayCallback} from "@morpho-blue/interfaces/IBlueCallbacks.sol";
import {IIrm} from "@morpho-blue/interfaces/IIrm.sol";
import {IERC20} from "@morpho-blue/interfaces/IERC20.sol";
import {IOracle} from "@morpho-blue/interfaces/IOracle.sol";
import {SafeTransferLib, ERC20} from "@solmate/utils/SafeTransferLib.sol";
import {FixedPointMathLib} from "@solmate/utils/FixedPointMathLib.sol";

contract PriceDutchLiquidationModule {
    using MarketLib for Market;
    using FixedPointMathLib for uint256;
    using SafeTransferLib for ERC20;

    IBlue public immutable blue;

    struct PriceDutchParams {
        uint256 minCloseFactor;
        uint256 maxCloseFactor;
        uint256 minLiquidationFee;
        uint256 maxLiquidationFee;
        uint256 lltvStart;
    }

    mapping(address borrower => mapping(Id market => PriceDutchParams)) internal _priceDutchParams;

    constructor(address newBlue) {
        blue = IBlue(newBlue);
    }

    function setPriceDutchParams(Market memory market, PriceDutchParams memory params) external {
        require(params.maxCloseFactor <= FixedPointMathLib.WAD, "PriceDutchLiquidationModule: maxCloseFactor > 1");
        require(
            params.maxLiquidationFee <= (FixedPointMathLib.WAD - market.lltv) / 2,
            "PriceDutchLiquidationModule: maxLiquidationFee > blue"
        );
        require(params.lltvStart <= market.lltv, "PriceDutchLiquidationModule: lltvStart > market lltv");
        _priceDutchParams[msg.sender][market.id()] = params;
    }

    function liquidate(Market memory market, address borrower, uint256 toRepay) external {
        uint256 collateral = collateralReceivedForDebt(market, borrower, toRepay);

        ERC20(address(market.borrowableAsset)).safeTransferFrom(msg.sender, address(this), toRepay);

        _approveMaxBlue(address(market.borrowableAsset));
        blue.repay(market, toRepay, borrower, "");
        blue.withdrawCollateral(market, collateral, borrower);

        ERC20(address(market.collateralAsset)).safeTransfer(msg.sender, collateral);
    }

    function collateralReceivedForDebt(Market memory market, address borrower, uint256 debt)
        public
        view
        returns (uint256)
    {
        Id id = market.id();
        PriceDutchParams memory params = _priceDutchParams[borrower][id];

        uint256 collateral = blue.collateral(id, borrower);
        uint256 borrow =
            SharesMath.toAssetsUp(blue.borrowShare(id, borrower), blue.totalBorrow(id), blue.totalBorrowShares(id)); // TODO: Use virtually updated total borrow.

        uint256 collateralPrice = market.collateralOracle.price();
        uint256 borrowPrice = market.borrowableOracle.price();

        uint256 currentLltv = borrow.mulWadUp(borrowPrice).mulWadUp(collateral.mulWadDown(collateralPrice));

        // Close factor and liquidation bonus scale linearly with the current lltv.
        uint256 cursor = (currentLltv - params.lltvStart).divWadDown(market.lltv - params.lltvStart);
        uint256 closeFactor = params.minCloseFactor + cursor.mulWadDown(params.maxCloseFactor - params.minCloseFactor);
        uint256 liquidationFee =
            params.minLiquidationFee + cursor.mulWadDown(params.maxLiquidationFee - params.minLiquidationFee);

        require(debt < borrow, "PriceDutchLiquidationModule: debt >= borrow");
        require(
            currentLltv < market.lltv && currentLltv > params.lltvStart,
            "PriceDutchLiquidationModule: currentLltv not in range"
        );
        require(debt.divWadUp(borrow) < closeFactor, "PriceDutchLiquidationModule: debt / borrow >= closeFactor");

        return debt.divWadDown(collateralPrice).mulWadDown(FixedPointMathLib.WAD + liquidationFee);
    }

    /// @dev Gives the max approval to the Morpho contract to spend the given `asset` if not already approved.
    function _approveMaxBlue(address asset) private {
        if (ERC20(asset).allowance(address(this), address(blue)) == 0) {
            ERC20(asset).safeApprove(address(blue), type(uint256).max);
        }
    }
}
