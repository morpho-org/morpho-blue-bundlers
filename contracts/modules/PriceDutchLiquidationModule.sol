// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.21;

import {MarketLib, Id, Market} from "@morpho-blue/libraries/MarketLib.sol";
import {SharesMathLib} from "@morpho-blue/libraries/SharesMathLib.sol";
import {IMorpho} from "@morpho-blue/interfaces/IMorpho.sol";
import {MAX_LIQUIDATION_INCENTIVE_FACTOR, LIQUIDATION_CURSOR, WAD, ORACLE_PRICE_SCALE} from "@morpho-blue/Morpho.sol";
import {IMorphoRepayCallback} from "@morpho-blue/interfaces/IMorphoCallbacks.sol";
import {IIrm} from "@morpho-blue/interfaces/IIrm.sol";
import {IERC20} from "@morpho-blue/interfaces/IERC20.sol";
import {IOracle} from "@morpho-blue/interfaces/IOracle.sol";
import {SafeTransferLib, ERC20} from "@solmate/utils/SafeTransferLib.sol";
import {FixedPointMathLib} from "@solmate/utils/FixedPointMathLib.sol";
import {Math} from "@morpho-utils/math/Math.sol";

contract PriceDutchLiquidationModule {
    using MarketLib for Market;
    using FixedPointMathLib for uint256;
    using SafeTransferLib for ERC20;

    IMorpho public immutable morpho;

    struct PriceDutchParams {
        uint256 minCloseFactor;
        uint256 maxCloseFactor;
        uint256 minLiquidationFee;
        uint256 maxLiquidationFee;
        uint256 lltvStart;
    }

    mapping(address borrower => mapping(Id market => PriceDutchParams)) internal _priceDutchParams;

    constructor(address newMorpho) {
        morpho = IMorpho(newMorpho);
    }

    function setPriceDutchParams(Market memory market, PriceDutchParams memory params) external {
        require(params.maxCloseFactor <= FixedPointMathLib.WAD, "PriceDutchLiquidationModule: maxCloseFactor > 1");
        require(
            params.maxLiquidationFee <= _liquidationIncentive(market.lltv),
            "PriceDutchLiquidationModule: maxLiquidationFee > morpho liquidation incentive"
        );
        require(params.lltvStart <= market.lltv, "PriceDutchLiquidationModule: lltvStart > market lltv");
        _priceDutchParams[msg.sender][market.id()] = params;
    }

    function liquidate(Market memory market, address borrower, uint256 toRepay) external {
        morpho.accrueInterests(market);
        uint256 collateral = collateralReceivedForDebt(market, borrower, toRepay);

        ERC20(address(market.borrowableToken)).safeTransferFrom(msg.sender, address(this), toRepay);

        _approveMaxMorpho(address(market.borrowableToken));
        morpho.repay(market, toRepay, 0, borrower, "");
        morpho.withdrawCollateral(market, collateral, borrower, msg.sender);
    }

    /// @dev Does not account for accrued interest. Call accrueInterests on Morpho before calling this to get an accurate figure.
    function collateralReceivedForDebt(Market memory market, address borrower, uint256 debt)
        public
        view
        returns (uint256)
    {
        Id id = market.id();
        PriceDutchParams memory params = _priceDutchParams[borrower][id];

        uint256 collateral = morpho.collateral(id, borrower);
        uint256 borrow = SharesMathLib.toAssetsUp(
            morpho.borrowShares(id, borrower), morpho.totalBorrow(id), morpho.totalBorrowShares(id)
        );

        uint256 price = IOracle(market.oracle).price();

        uint256 currentLltv = borrow.divWadUp(collateral.mulDivDown(price, ORACLE_PRICE_SCALE));

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

        return debt.mulDivDown(ORACLE_PRICE_SCALE, price).mulWadDown(FixedPointMathLib.WAD + liquidationFee);
    }

    /// @dev Gives the max approval to the Morpho contract to spend the given `asset` if not already approved.
    function _approveMaxMorpho(address asset) private {
        if (ERC20(asset).allowance(address(this), address(morpho)) == 0) {
            ERC20(asset).safeApprove(address(morpho), type(uint256).max);
        }
    }

    /// @dev The liquidation incentive factor is min(maxIncentiveFactor, 1/(1 - cursor(1 - lltv))).
    function _liquidationIncentive(uint256 lltv) private pure returns (uint256) {
        return Math.min(
            MAX_LIQUIDATION_INCENTIVE_FACTOR, WAD.divWadDown(WAD - LIQUIDATION_CURSOR.mulWadDown(WAD - lltv))
        ) - WAD;
    }
}
