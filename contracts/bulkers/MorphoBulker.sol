// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.21;

import {IMorphoBulker} from "./interfaces/IMorphoBulker.sol";
import {Market, Signature, Authorization, IMorpho} from "@morpho-blue/interfaces/IMorpho.sol";
import {ErrorsLib as MorphoErrorsLib} from "@morpho-blue/libraries/ErrorsLib.sol";

import {Errors} from "./libraries/Errors.sol";

import {Math} from "@morpho-utils/math/Math.sol";
import {SafeTransferLib, ERC20} from "@solmate/utils/SafeTransferLib.sol";

import {BaseBulker} from "./BaseBulker.sol";

/// @title MorphoBulker.
/// @author Morpho Labs.
/// @custom:contact security@blue.xyz
abstract contract MorphoBulker is BaseBulker, IMorphoBulker {
    using SafeTransferLib for ERC20;

    /* IMMUTABLES */

    IMorpho public immutable MORPHO;

    /* CONSTRUCTOR */

    constructor(address morpho) {
        require(morpho != address(0), Errors.ZERO_ADDRESS);

        MORPHO = IMorpho(morpho);
    }

    /* MODIFIERS */

    modifier callback(bytes calldata data) {
        _checkInitiated();

        _multicall(abi.decode(data, (bytes[])));

        _;
    }

    /* CALLBACKS */

    function onMorphoSupply(uint256, bytes calldata data) external callback(data) {
        // Don't need to approve Blue to pull tokens because it should already be approved max.
    }

    function onMorphoSupplyCollateral(uint256, bytes calldata data) external callback(data) {
        // Don't need to approve Blue to pull tokens because it should already be approved max.
    }

    function onMorphoRepay(uint256, bytes calldata data) external callback(data) {
        // Don't need to approve Blue to pull tokens because it should already be approved max.
    }

    function onMorphoFlashLoan(uint256, bytes calldata data) external callback(data) {
        // Don't need to approve Blue to pull tokens because it should already be approved max.
    }

    /* ACTIONS */

    /// @dev Approves this contract to manage the initiator's position via EIP712 `signature`.
    function morphoSetAuthorizationWithSig(Authorization calldata authorization, Signature calldata signature)
        external
    {
        try MORPHO.setAuthorizationWithSig(authorization, signature) {
            return;
        } catch Error(string memory reason) {
            // Do not revert if someone frontran the transaction.
            if (keccak256(bytes(reason)) == keccak256(bytes(MorphoErrorsLib.INVALID_NONCE))) return;
            else revert(reason);
        }
    }

    /// @dev Supplies `amount` of `asset` of `onBehalf` using permit2 in a single tx.
    ///      The supplied amount cannot be used as collateral but is eligible to earn interest.
    ///      Note: pass `amount = type(uint256).max` to supply the bulker's borrowable asset balance.
    function morphoSupply(Market calldata market, uint256 amount, uint256 shares, address onBehalf, bytes calldata data)
        external
    {
        require(onBehalf != address(this), Errors.BULKER_ADDRESS);

        // Don't always cap the amount to the bulker's balance because the liquidity can be transferred inside the supply callback.
        if (amount == type(uint256).max) amount = ERC20(market.borrowableToken).balanceOf(address(this));

        _approveMaxBlue(market.borrowableToken);

        MORPHO.supply(market, amount, shares, onBehalf, data);
    }

    /// @dev Supplies `amount` of `asset` collateral to the pool on behalf of `onBehalf`.
    ///      Note: pass `amount = type(uint256).max` to supply the bulker's collateral asset balance.
    function morphoSupplyCollateral(Market calldata market, uint256 amount, address onBehalf, bytes calldata data)
        external
    {
        require(onBehalf != address(this), Errors.BULKER_ADDRESS);

        // Don't always cap the amount to the bulker's balance because the liquidity can be transferred inside the supply collateral callback.
        if (amount == type(uint256).max) amount = ERC20(market.collateralToken).balanceOf(address(this));

        _approveMaxBlue(market.collateralToken);

        MORPHO.supplyCollateral(market, amount, onBehalf, data);
    }

    /// @dev Borrows `amount` of `asset` on behalf of the sender. Sender must have previously approved the bulker as their manager on Blue.
    function morphoBorrow(Market calldata market, uint256 amount, uint256 shares, address receiver) external {
        MORPHO.borrow(market, amount, shares, _initiator, receiver);
    }

    /// @dev Repays `amount` of `asset` on behalf of `onBehalf`.
    ///      Note: pass `amount = type(uint256).max` to repay the bulker's borrowable asset balance.
    function morphoRepay(Market calldata market, uint256 amount, uint256 shares, address onBehalf, bytes calldata data)
        external
    {
        require(onBehalf != address(this), Errors.BULKER_ADDRESS);

        // Don't always cap the amount to the bulker's balance because the liquidity can be transferred inside the repay callback.
        if (amount == type(uint256).max) amount = ERC20(market.borrowableToken).balanceOf(address(this));

        _approveMaxBlue(market.borrowableToken);

        MORPHO.repay(market, amount, shares, onBehalf, data);
    }

    /// @dev Withdraws `amount` of the borrowable asset on behalf of `onBehalf`. Sender must have previously authorized the bulker to act on their behalf on Blue.
    function morphoWithdraw(Market calldata market, uint256 amount, uint256 shares, address receiver) external {
        MORPHO.withdraw(market, amount, shares, _initiator, receiver);
    }

    /// @dev Withdraws `amount` of the collateral asset on behalf of sender. Sender must have previously authorized the bulker to act on their behalf on Blue.
    function morphoWithdrawCollateral(Market calldata market, uint256 amount, address receiver) external {
        MORPHO.withdrawCollateral(market, amount, _initiator, receiver);
    }

    /// @dev Triggers a liquidation on Blue.
    function morphoLiquidate(Market calldata market, address borrower, uint256 seized, bytes memory data) external {
        _approveMaxBlue(market.borrowableToken);

        MORPHO.liquidate(market, borrower, seized, data);
    }

    /// @dev Triggers a flash loan on Blue.
    function morphoFlashLoan(address asset, uint256 amount, bytes calldata data) external {
        _approveMaxBlue(asset);

        MORPHO.flashLoan(asset, amount, data);
    }

    /* PRIVATE */

    /// @dev Gives the max approval to the Blue contract to spend the given `asset` if not already approved.
    function _approveMaxBlue(address asset) private {
        if (ERC20(asset).allowance(address(this), address(MORPHO)) == 0) {
            ERC20(asset).safeApprove(address(MORPHO), type(uint256).max);
        }
    }
}
