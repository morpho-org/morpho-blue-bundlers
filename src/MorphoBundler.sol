// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.21;

import {IMorphoBundler} from "./interfaces/IMorphoBundler.sol";
import {MarketParams, Signature, Authorization, IMorpho} from "@morpho-blue/interfaces/IMorpho.sol";

import {ErrorsLib} from "./libraries/ErrorsLib.sol";

import {Math} from "@morpho-utils/math/Math.sol";
import {SafeTransferLib, ERC20} from "solmate/src/utils/SafeTransferLib.sol";

import {BaseBundler} from "./BaseBundler.sol";

/// @title MorphoBundler
/// @author Morpho Labs
/// @custom:contact security@morpho.org
/// @notice Bundler contract managing interactions with Morpho.
abstract contract MorphoBundler is BaseBundler, IMorphoBundler {
    using SafeTransferLib for ERC20;

    /* IMMUTABLES */

    /// @notice The Morpho contract address.
    IMorpho public immutable MORPHO;

    /* CONSTRUCTOR */

    constructor(address morpho) {
        require(morpho != address(0), ErrorsLib.ZERO_ADDRESS);

        MORPHO = IMorpho(morpho);
    }

    /* CALLBACKS */

    function onMorphoSupply(uint256, bytes calldata data) external {
        // Don't need to approve Blue to pull tokens because it should already be approved max.
        _callback(data);
    }

    function onMorphoSupplyCollateral(uint256, bytes calldata data) external {
        // Don't need to approve Blue to pull tokens because it should already be approved max.
        _callback(data);
    }

    function onMorphoRepay(uint256, bytes calldata data) external {
        // Don't need to approve Blue to pull tokens because it should already be approved max.
        _callback(data);
    }

    function onMorphoFlashLoan(uint256, bytes calldata data) external {
        // Don't need to approve Blue to pull tokens because it should already be approved max.
        _callback(data);
    }

    /* ACTIONS */

    /// @notice Approves this contract to manage the `authorization.authorizer`'s position via EIP712 `signature`.
    function morphoSetAuthorizationWithSig(Authorization calldata authorization, Signature calldata signature)
        external
        payable
    {
        MORPHO.setAuthorizationWithSig(authorization, signature);
    }

    /// @notice Supplies `amount` of `asset` of `onBehalf` using permit2 in a single tx.
    /// @notice The supplied amount cannot be used as collateral but is eligible to earn interest.
    /// @dev Pass `amount = type(uint256).max` to supply the bundler's loan asset balance.
    function morphoSupply(
        MarketParams calldata marketParams,
        uint256 amount,
        uint256 shares,
        address onBehalf,
        bytes calldata data
    ) external payable {
        // Do not check `onBehalf` against the zero address as it's done at Morpho's level.
        require(onBehalf != address(this), ErrorsLib.BUNDLER_ADDRESS);

        // Don't always cap the amount to the bundler's balance because the liquidity can be transferred later
        // (via the `onMorphoSupply` callback).
        if (amount == type(uint256).max) amount = ERC20(marketParams.loanToken).balanceOf(address(this));

        _approveMaxBlue(marketParams.loanToken);

        MORPHO.supply(marketParams, amount, shares, onBehalf, data);
    }

    /// @notice Supplies `amount` of `asset` collateral to the pool on behalf of `onBehalf`.
    /// @dev Pass `amount = type(uint256).max` to supply the bundler's collateral asset balance.
    function morphoSupplyCollateral(
        MarketParams calldata marketParams,
        uint256 amount,
        address onBehalf,
        bytes calldata data
    ) external payable {
        // Do not check `onBehalf` against the zero address as it's done at Morpho's level.
        require(onBehalf != address(this), ErrorsLib.BUNDLER_ADDRESS);

        // Don't always cap the amount to the bundler's balance because the liquidity can be transferred later
        // (via the `onMorphoSupplyCollateral` callback).
        if (amount == type(uint256).max) amount = ERC20(marketParams.collateralToken).balanceOf(address(this));

        _approveMaxBlue(marketParams.collateralToken);

        MORPHO.supplyCollateral(marketParams, amount, onBehalf, data);
    }

    /// @notice Borrows `amount` of `asset` on behalf of the sender.
    /// @notice Warning: should only be called via the bundler's `multicall` function.
    /// @dev Initiator must have previously authorized the bundler to act on their behalf on Blue.
    function morphoBorrow(MarketParams calldata marketParams, uint256 amount, uint256 shares, address receiver)
        external
        payable
    {
        MORPHO.borrow(marketParams, amount, shares, _initiator, receiver);
    }

    /// @notice Repays `amount` of `asset` on behalf of `onBehalf`.
    /// @dev Pass `amount = type(uint256).max` to repay the bundler's loan asset balance.
    function morphoRepay(
        MarketParams calldata marketParams,
        uint256 amount,
        uint256 shares,
        address onBehalf,
        bytes calldata data
    ) external payable {
        // Do not check `onBehalf` against the zero address as it's done at Morpho's level.
        require(onBehalf != address(this), ErrorsLib.BUNDLER_ADDRESS);

        // Don't always cap the amount to the bundler's balance because the liquidity can be transferred later
        // (via the `onMorphoRepay` callback).
        if (amount == type(uint256).max) amount = ERC20(marketParams.loanToken).balanceOf(address(this));

        _approveMaxBlue(marketParams.loanToken);

        MORPHO.repay(marketParams, amount, shares, onBehalf, data);
    }

    /// @notice Withdraws `amount` of the loan asset on behalf of `onBehalf`.
    /// @notice Warning: should only be called via the bundler's `multicall` function.
    /// @dev Initiator must have previously authorized the bundler to act on their behalf on Blue.
    function morphoWithdraw(MarketParams calldata marketParams, uint256 amount, uint256 shares, address receiver)
        external
        payable
    {
        MORPHO.withdraw(marketParams, amount, shares, _initiator, receiver);
    }

    /// @notice Withdraws `amount` of the collateral asset on behalf of sender.
    /// @notice Warning: should only be called via the bundler's `multicall` function.
    /// @dev Initiator must have previously authorized the bundler to act on their behalf on Blue.
    function morphoWithdrawCollateral(MarketParams calldata marketParams, uint256 amount, address receiver)
        external
        payable
    {
        MORPHO.withdrawCollateral(marketParams, amount, _initiator, receiver);
    }

    /// @notice Triggers a liquidation on Blue.
    function morphoLiquidate(
        MarketParams calldata marketParams,
        address borrower,
        uint256 seizedAssets,
        uint256 repaidShares,
        bytes memory data
    ) external payable {
        _approveMaxBlue(marketParams.loanToken);

        MORPHO.liquidate(marketParams, borrower, seizedAssets, repaidShares, data);
    }

    /// @notice Triggers a flash loan on Blue.
    function morphoFlashLoan(address asset, uint256 amount, bytes calldata data) external payable {
        _approveMaxBlue(asset);

        MORPHO.flashLoan(asset, amount, data);
    }

    /* INTERNAL */

    /// @dev Triggers `_multicall` logic during a callback.
    function _callback(bytes calldata data) internal {
        _checkInitiated();
        _multicall(abi.decode(data, (bytes[])));
    }

    /// @dev Gives the max approval to the Blue contract to spend the given `asset` if not already approved.
    function _approveMaxBlue(address asset) internal {
        if (ERC20(asset).allowance(address(this), address(MORPHO)) == 0) {
            ERC20(asset).safeApprove(address(MORPHO), type(uint256).max);
        }
    }
}
