// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.21;

import {IMorphoBulker} from "./interfaces/IMorphoBulker.sol";
import {Market, Signature, IMorpho, Authorization} from "@morpho-blue/interfaces/IMorpho.sol";

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

    /* CALLBACKS */

    function onMorphoSupply(uint256, bytes calldata data) external {
        _multicall(abi.decode(data, (bytes[])));
    }

    function onMorphoSupplyCollateral(uint256, bytes calldata data) external {
        _multicall(abi.decode(data, (bytes[])));
    }

    function onMorphoRepay(uint256, bytes calldata data) external {
        _multicall(abi.decode(data, (bytes[])));
    }

    function onMorphoFlashLoan(uint256, bytes calldata data) external {
        _multicall(abi.decode(data, (bytes[])));
    }

    /* ACTIONS */

    /// @dev Approves this contract to manage the position of `msg.sender` via EIP712 `signature`.
    function morphoSetAuthorizationWithSig(address authorizer, bool isAuthorized, uint256 nonce, uint256 deadline, Signature calldata signature)
        external
    {
        MORPHO.setAuthorizationWithSig(Authorization({authorizer: authorizer, authorized: address(this), isAuthorized: isAuthorized, nonce: nonce, deadline: deadline}), signature);
    }

    /// @dev Supplies `amount` of `asset` of `onBehalf` using permit2 in a single tx.
    ///         The supplied amount cannot be used as collateral but is eligible for the peer-to-peer matching.
    function morphoSupply(Market calldata market, uint256 amount, address onBehalf, bytes calldata data) external {
        require(onBehalf != address(this), Errors.BULKER_ADDRESS);

        amount = Math.min(amount, ERC20(market.borrowableToken).balanceOf(address(this)));

        _approveMaxBlue(market.borrowableToken);

        MORPHO.supply(market, amount, 0, onBehalf, data);
    }

    /// @dev Supplies `amount` of `asset` collateral to the pool on behalf of `onBehalf`.
    function morphoSupplyCollateral(Market calldata market, uint256 amount, address onBehalf, bytes calldata data)
        external
    {
        require(onBehalf != address(this), Errors.BULKER_ADDRESS);

        amount = Math.min(amount, ERC20(market.collateralToken).balanceOf(address(this)));

        _approveMaxBlue(market.collateralToken);

        MORPHO.supplyCollateral(market, amount, onBehalf, data);
    }

    /// @dev Borrows `amount` of `asset` on behalf of the sender. Sender must have previously approved the bulker as their manager on Morpho.
    function morphoBorrow(Market calldata market, uint256 amount, address receiver) external {
        MORPHO.borrow(market, amount, 0, msg.sender, receiver);
    }

    /// @dev Repays `amount` of `asset` on behalf of `onBehalf`.
    function morphoRepay(Market calldata market, uint256 amount, address onBehalf, bytes calldata data) external {
        require(onBehalf != address(this), Errors.BULKER_ADDRESS);

        amount = Math.min(amount, ERC20(market.borrowableToken).balanceOf(address(this)));

        _approveMaxBlue(market.borrowableToken);

        MORPHO.repay(market, amount, 0, onBehalf, data);
    }

    /// @dev Withdraws `amount` of `asset` on behalf of `onBehalf`. Sender must have previously approved the bulker as their manager on Morpho.
    function morphoWithdraw(Market calldata market, uint256 amount, address receiver) external {
        MORPHO.withdraw(market, amount, 0, msg.sender, receiver);
    }

    /// @dev Withdraws `amount` of `asset` on behalf of sender. Sender must have previously approved the bulker as their manager on Morpho.
    function morphoWithdrawCollateral(Market calldata market, uint256 amount, address receiver) external {
        MORPHO.withdrawCollateral(market, amount, msg.sender, receiver);
    }

    /// @dev Triggers a flash loan on Blue.
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

    /// @dev Gives the max approval to the Morpho contract to spend the given `asset` if not already approved.
    function _approveMaxBlue(address asset) private {
        if (ERC20(asset).allowance(address(this), address(MORPHO)) == 0) {
            ERC20(asset).safeApprove(address(MORPHO), type(uint256).max);
        }
    }
}
