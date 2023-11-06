// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.21;

import {IMorphoBundler} from "./interfaces/IMorphoBundler.sol";
import {MarketParams, Signature, Authorization, IMorpho} from "../lib/morpho-blue/src/interfaces/IMorpho.sol";

import {ErrorsLib} from "./libraries/ErrorsLib.sol";
import {SafeTransferLib, ERC20} from "../lib/solmate/src/utils/SafeTransferLib.sol";

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
        // Don't need to approve Morpho to pull tokens because it should already be approved max.
        _callback(data);
    }

    function onMorphoSupplyCollateral(uint256, bytes calldata data) external {
        // Don't need to approve Morpho to pull tokens because it should already be approved max.
        _callback(data);
    }

    function onMorphoRepay(uint256, bytes calldata data) external {
        // Don't need to approve Morpho to pull tokens because it should already be approved max.
        _callback(data);
    }

    function onMorphoLiquidate(uint256, bytes calldata data) external {
        // Don't need to approve Morpho to pull tokens because it should already be approved max.
        _callback(data);
    }

    function onMorphoFlashLoan(uint256, bytes calldata data) external {
        // Don't need to approve Morpho to pull tokens because it should already be approved max.
        _callback(data);
    }

    /* ACTIONS */

    /// @notice Approves this contract to manage the `authorization.authorizer`'s position via EIP712 `signature`.
    /// @param authorization The `Authorization` struct.
    /// @param signature The signature.
    /// @param skipRevert Whether to avoid reverting the call in case the signature is frontrunned.
    function morphoSetAuthorizationWithSig(
        Authorization calldata authorization,
        Signature calldata signature,
        bool skipRevert
    ) external payable {
        try MORPHO.setAuthorizationWithSig(authorization, signature) {}
        catch (bytes memory returnData) {
            if (!skipRevert) _revert(returnData);
        }
    }

    /// @notice Supplies `assets` of the loan asset on behalf of `onBehalf`.
    /// @notice The supplied assets cannot be used as collateral but is eligible to earn interest.
    /// @dev Either `assets` or `shares` should be zero. Most usecases should rely on `assets` as an input so the
    /// bundler is guaranteed to have `assets` tokens pulled from its balance, but the possibility to mint a specific
    /// amount of shares is given for full compatibility and precision.
    /// @dev Initiator must have previously transferred their assets to the bundler.
    /// @param marketParams The Morpho market to supply assets to.
    /// @param assets The amount of assets to supply. Pass `type(uint256).max` to supply the bundler's loan asset
    /// balance.
    /// @param shares The amount of shares to mint.
    /// @param slippageAmount The minimum amount of shares to mint in exchange for `assets` when it is used.
    /// The maximum amount of assets to deposit in exchange for `shares` otherwise.
    /// @param onBehalf The address that will own the increased supply position.
    /// @param data Arbitrary data to pass to the `onMorphoSupply` callback. Pass empty data if not needed.
    function morphoSupply(
        MarketParams calldata marketParams,
        uint256 assets,
        uint256 shares,
        uint256 slippageAmount,
        address onBehalf,
        bytes calldata data
    ) external payable {
        // Do not check `onBehalf` against the zero address as it's done at Morpho's level.
        require(onBehalf != address(this), ErrorsLib.BUNDLER_ADDRESS);

        // Don't always cap the assets to the bundler's balance because the liquidity can be transferred later
        // (via the `onMorphoSupply` callback).
        if (assets == type(uint256).max) assets = ERC20(marketParams.loanToken).balanceOf(address(this));

        _approveMaxTo(marketParams.loanToken, address(MORPHO));

        (uint256 suppliedAssets, uint256 suppliedShares) = MORPHO.supply(marketParams, assets, shares, onBehalf, data);

        if (assets > 0) require(suppliedShares >= slippageAmount, ErrorsLib.SLIPPAGE_EXCEEDED);
        else require(suppliedAssets <= slippageAmount, ErrorsLib.SLIPPAGE_EXCEEDED);
    }

    /// @notice Supplies `assets` of collateral on behalf of `onBehalf`.
    /// @dev Initiator must have previously transferred their assets to the bundler.
    /// @param marketParams The Morpho market to supply collateral to.
    /// @param assets The amount of collateral to supply. Pass `type(uint256).max` to supply the bundler's loan asset
    /// balance.
    /// @param onBehalf The address that will own the increased collateral position.
    /// @param data Arbitrary data to pass to the `onMorphoSupplyCollateral` callback. Pass empty data if not needed.
    function morphoSupplyCollateral(
        MarketParams calldata marketParams,
        uint256 assets,
        address onBehalf,
        bytes calldata data
    ) external payable {
        // Do not check `onBehalf` against the zero address as it's done at Morpho's level.
        require(onBehalf != address(this), ErrorsLib.BUNDLER_ADDRESS);

        // Don't always cap the assets to the bundler's balance because the liquidity can be transferred later
        // (via the `onMorphoSupplyCollateral` callback).
        if (assets == type(uint256).max) assets = ERC20(marketParams.collateralToken).balanceOf(address(this));

        _approveMaxTo(marketParams.collateralToken, address(MORPHO));

        MORPHO.supplyCollateral(marketParams, assets, onBehalf, data);
    }

    /// @notice Borrows `assets` of the loan asset on behalf of the initiator.
    /// @notice Warning: should only be called via the bundler's `multicall` function.
    /// @dev Either `assets` or `shares` should be zero. Most usecases should rely on `assets` as an input so the
    /// initiator is guaranteed to borrow `assets` tokens, but the possibility to mint a specific amount of shares is
    /// given for full compatibility and precision.
    /// @dev Initiator must have previously authorized the bundler to act on their behalf on Morpho.
    /// @param marketParams The Morpho market to borrow assets from.
    /// @param assets The amount of assets to borrow.
    /// @param shares The amount of shares to mint.
    /// @param slippageAmount The maximum amount of shares to mint in exchange for `assets` when it is used.
    /// The minimum amount of assets to borrow in exchange for `shares` otherwise.
    /// @param receiver The address that will receive the borrowed assets.
    function morphoBorrow(
        MarketParams calldata marketParams,
        uint256 assets,
        uint256 shares,
        uint256 slippageAmount,
        address receiver
    ) external payable {
        (uint256 borrowedAssets, uint256 borrowedShares) =
            MORPHO.borrow(marketParams, assets, shares, initiator(), receiver);

        if (assets > 0) require(borrowedShares <= slippageAmount, ErrorsLib.SLIPPAGE_EXCEEDED);
        else require(borrowedAssets >= slippageAmount, ErrorsLib.SLIPPAGE_EXCEEDED);
    }

    /// @notice Repays `assets` of the loan asset on behalf of `onBehalf`.
    /// @dev Either `assets` or `shares` should be zero. Most usecases should rely on `assets` as an input so the
    /// bundler is guaranteed to have `assets` tokens pulled from its balance, but the possibility to mint a specific
    /// amount of shares is given for full compatibility and precision.
    /// @param marketParams The Morpho market to repay assets to.
    /// @param assets The amount of assets to repay. Pass `type(uint256).max` to repay the bundler's loan asset balance.
    /// @param shares The amount of shares to burn.
    /// @param slippageAmount The minimum amount of shares to mint in exchange for `assets` when it is used.
    /// The maximum amount of assets to deposit in exchange for `shares` otherwise.
    /// @param onBehalf The address of the owner of the debt position.
    /// @param data Arbitrary data to pass to the `onMorphoRepay` callback. Pass empty data if not needed.
    function morphoRepay(
        MarketParams calldata marketParams,
        uint256 assets,
        uint256 shares,
        uint256 slippageAmount,
        address onBehalf,
        bytes calldata data
    ) external payable {
        // Do not check `onBehalf` against the zero address as it's done at Morpho's level.
        require(onBehalf != address(this), ErrorsLib.BUNDLER_ADDRESS);

        // Don't always cap the assets to the bundler's balance because the liquidity can be transferred later
        // (via the `onMorphoRepay` callback).
        if (assets == type(uint256).max) assets = ERC20(marketParams.loanToken).balanceOf(address(this));

        _approveMaxTo(marketParams.loanToken, address(MORPHO));

        (uint256 repaidAssets, uint256 repaidShares) = MORPHO.repay(marketParams, assets, shares, onBehalf, data);

        if (assets > 0) require(repaidShares >= slippageAmount, ErrorsLib.SLIPPAGE_EXCEEDED);
        else require(repaidAssets <= slippageAmount, ErrorsLib.SLIPPAGE_EXCEEDED);
    }

    /// @notice Withdraws `assets` of the loan asset on behalf of the initiator.
    /// @notice Warning: should only be called via the bundler's `multicall` function.
    /// @dev Either `assets` or `shares` should be zero. Most usecases should rely on `assets` as an input so the
    /// initiator is guaranteed to withdraw `assets` tokens, but the possibility to mint a specific amount of shares is
    /// given for full compatibility and precision.
    /// @dev Initiator must have previously authorized the bundler to act on their behalf on Morpho.
    /// @param marketParams The Morpho market to withdraw assets from.
    /// @param assets The amount of assets to withdraw.
    /// @param shares The amount of shares to burn.
    /// @param slippageAmount The minimum amount of shares to mint in exchange for `assets` when it is used.
    /// The maximum amount of assets to deposit in exchange for `shares` otherwise.
    /// @param receiver The address that will receive the withdrawn assets.
    function morphoWithdraw(
        MarketParams calldata marketParams,
        uint256 assets,
        uint256 shares,
        uint256 slippageAmount,
        address receiver
    ) external payable {
        (uint256 withdrawnAssets, uint256 withdrawnShares) =
            MORPHO.withdraw(marketParams, assets, shares, initiator(), receiver);

        if (assets > 0) require(withdrawnShares <= slippageAmount, ErrorsLib.SLIPPAGE_EXCEEDED);
        else require(withdrawnAssets >= slippageAmount, ErrorsLib.SLIPPAGE_EXCEEDED);
    }

    /// @notice Withdraws `assets` of the collateral asset on behalf of the initiator.
    /// @notice Warning: should only be called via the bundler's `multicall` function.
    /// @dev Initiator must have previously authorized the bundler to act on their behalf on Morpho.
    /// @param marketParams The Morpho market to withdraw collateral from.
    /// @param assets The amount of collateral to withdraw.
    /// @param receiver The address that will receive the collateral assets.
    function morphoWithdrawCollateral(MarketParams calldata marketParams, uint256 assets, address receiver)
        external
        payable
    {
        MORPHO.withdrawCollateral(marketParams, assets, initiator(), receiver);
    }

    /// @notice Triggers a liquidation on Morpho.
    /// @notice Seized collateral is received by the bundler and should be used afterwards.
    /// @dev Either `seizedAssets` or `repaidShares` should be zero.
    /// @param marketParams The Morpho market of the position.
    /// @param borrower The owner of the position.
    /// @param seizedAssets The amount of collateral to seize.
    /// @param repaidShares The amount of shares to repay.
    /// @param maxRepaidAssets The maximum amount of assets to repay.
    /// @param data Arbitrary data to pass to the `onMorphoLiquidate` callback. Pass empty data if not needed.
    function morphoLiquidate(
        MarketParams calldata marketParams,
        address borrower,
        uint256 seizedAssets,
        uint256 repaidShares,
        uint256 maxRepaidAssets,
        bytes memory data
    ) external payable {
        _approveMaxTo(marketParams.loanToken, address(MORPHO));

        (, uint256 repaidAssets) = MORPHO.liquidate(marketParams, borrower, seizedAssets, repaidShares, data);

        require(repaidAssets <= maxRepaidAssets, ErrorsLib.SLIPPAGE_EXCEEDED);
    }

    /// @notice Triggers a flash loan on Morpho.
    /// @param token The address of the token to flash loan.
    /// @param assets The amount of assets to flash loan.
    /// @param data Arbitrary data to pass to the `onMorphoFlashLoan` callback.
    function morphoFlashLoan(address token, uint256 assets, bytes calldata data) external payable {
        _approveMaxTo(token, address(MORPHO));

        MORPHO.flashLoan(token, assets, data);
    }

    /* INTERNAL */

    /// @dev Triggers `_multicall` logic during a callback.
    function _callback(bytes calldata data) internal {
        _checkInitiated();

        _multicall(abi.decode(data, (bytes[])));
    }
}
