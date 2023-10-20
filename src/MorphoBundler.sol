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

    function onMorphoFlashLoan(uint256, bytes calldata data) external {
        // Don't need to approve Morpho to pull tokens because it should already be approved max.
        _callback(data);
    }

    /* ACTIONS */

    /// @notice Approves this contract to manage the `authorization.authorizer`'s position via EIP712 `signature`.
    /// @dev Pass `skipRevert == true` to avoid reverting the whole bundle in case the signature expired.
    /// @param authorization The `Authorization` struct.
    /// @param signature The signature.
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

    /// @notice Supplies `amount` of `asset` of `onBehalf` using permit2 in a single tx.
    /// @notice The supplied amount cannot be used as collateral but is eligible to earn interest.
    /// @dev Pass `amount = type(uint256).max` to supply the bundler's loan asset balance.
    /// @param marketParams The Morpho market to supply assets to.
    /// @param amount The amount of assets to supply.
    /// @param shares The amount of shares to mint.
    /// @param onBehalf The address that will own the increased supply position.
    /// @param data Arbitrary data to pass to the `onMorphoSupply` callback. Pass empty data if not needed.
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

        _approveMaxMorpho(marketParams.loanToken);

        MORPHO.supply(marketParams, amount, shares, onBehalf, data);
    }

    /// @notice Supplies `amount` of `asset` collateral to the pool on behalf of `onBehalf`.
    /// @dev Pass `amount = type(uint256).max` to supply the bundler's collateral asset balance.
    /// @param marketParams The Morpho market to supply collateral to.
    /// @param amount The amount of collateral to supply.
    /// @param onBehalf The address that will own the increased collateral position.
    /// @param data Arbitrary data to pass to the `onMorphoSupplyCollateral` callback. Pass empty data if not needed.
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

        _approveMaxMorpho(marketParams.collateralToken);

        MORPHO.supplyCollateral(marketParams, amount, onBehalf, data);
    }

    /// @notice Borrows `amount` of `asset` on behalf of the sender.
    /// @notice Warning: should only be called via the bundler's `multicall` function.
    /// @dev Initiator must have previously authorized the bundler to act on their behalf on Morpho.
    /// @param marketParams The Morpho market to borrow assets from.
    /// @param amount The amount of assets to borrow.
    /// @param shares The amount of shares to mint.
    /// @param receiver The address that will receive the borrowed assets.
    function morphoBorrow(MarketParams calldata marketParams, uint256 amount, uint256 shares, address receiver)
        external
        payable
    {
        MORPHO.borrow(marketParams, amount, shares, initiator, receiver);
    }

    /// @notice Repays `amount` of `asset` on behalf of `onBehalf`.
    /// @dev Pass `amount = type(uint256).max` to repay the bundler's loan asset balance.
    /// @param marketParams The Morpho market to repay assets to.
    /// @param amount The amount of assets to repay.
    /// @param shares The amount of shares to burn.
    /// @param onBehalf The address of the owner of the debt position.
    /// @param data Arbitrary data to pass to the `onMorphoRepay` callback. Pass empty data if not needed.
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

        _approveMaxMorpho(marketParams.loanToken);

        MORPHO.repay(marketParams, amount, shares, onBehalf, data);
    }

    /// @notice Withdraws `amount` of the loan asset on behalf of `onBehalf`.
    /// @notice Warning: should only be called via the bundler's `multicall` function.
    /// @dev Initiator must have previously authorized the bundler to act on their behalf on Morpho.
    /// @param marketParams The Morpho market to withdraw assets from.
    /// @param amount The amount of assets to withdraw.
    /// @param shares The amount of shares to burn.
    /// @param receiver The address that will receive the withdrawn assets.
    function morphoWithdraw(MarketParams calldata marketParams, uint256 amount, uint256 shares, address receiver)
        external
        payable
    {
        MORPHO.withdraw(marketParams, amount, shares, initiator, receiver);
    }

    /// @notice Withdraws `amount` of the collateral asset on behalf of sender.
    /// @notice Warning: should only be called via the bundler's `multicall` function.
    /// @dev Initiator must have previously authorized the bundler to act on their behalf on Morpho.
    /// @param marketParams The Morpho market to withdraw collateral from.
    /// @param amount The amount of collateral to withdraw.
    /// @param receiver The address that will receive the collateral assets.
    function morphoWithdrawCollateral(MarketParams calldata marketParams, uint256 amount, address receiver)
        external
        payable
    {
        MORPHO.withdrawCollateral(marketParams, amount, initiator, receiver);
    }

    /// @notice Triggers a liquidation on Morpho.
    /// @param marketParams The Morpho market of the position.
    /// @param borrower The owner of the position.
    /// @param seizedCollateral The amount of collateral to seize.
    /// @param repaidShares The amount of shares to repay.
    /// @param data Arbitrary data to pass to the `onMorphoLiquidate` callback. Pass empty data if not needed.
    function morphoLiquidate(
        MarketParams calldata marketParams,
        address borrower,
        uint256 seizedCollateral,
        uint256 repaidShares,
        bytes memory data
    ) external payable {
        _approveMaxMorpho(marketParams.loanToken);

        MORPHO.liquidate(marketParams, borrower, seizedCollateral, repaidShares, data);
    }

    /// @notice Triggers a flash loan on Morpho.
    /// @param token The address of the token to flash loan.
    /// @param amount The amount of assets to flash loan.
    /// @param data Arbitrary data to pass to the `onMorphoFlashLoan` callback.
    function morphoFlashLoan(address token, uint256 amount, bytes calldata data) external payable {
        _approveMaxMorpho(asset);

        MORPHO.flashLoan(asset, amount, data);
    }

    /* INTERNAL */

    /// @dev Triggers `_multicall` logic during a callback.
    function _callback(bytes calldata data) internal {
        _checkInitiated();

        _multicall(abi.decode(data, (bytes[])));
    }

    /// @dev Gives the max approval to the Morpho contract to spend the given `asset` if not already approved.
    function _approveMaxMorpho(address asset) internal {
        if (ERC20(asset).allowance(address(this), address(MORPHO)) == 0) {
            ERC20(asset).safeApprove(address(MORPHO), type(uint256).max);
        }
    }
}
