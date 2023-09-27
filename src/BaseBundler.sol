// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.21;

import {IWNative} from "./interfaces/IWNative.sol";
import {IERC4626} from "@openzeppelin/interfaces/IERC4626.sol";
import {IAllowanceTransfer} from "@permit2/interfaces/IAllowanceTransfer.sol";
import {IERC20Permit} from "@openzeppelin/token/ERC20/extensions/IERC20Permit.sol";

import {Math} from "@morpho-utils/math/Math.sol";
import {ErrorsLib} from "./libraries/ErrorsLib.sol";
import {Signature} from "@morpho-blue/interfaces/IMorpho.sol";
import {SafeCast160} from "@permit2/libraries/SafeCast160.sol";
import {ERC20, Permit2Lib} from "@permit2/libraries/Permit2Lib.sol";
import {SafeTransferLib, ERC20} from "solmate/src/utils/SafeTransferLib.sol";

import {BaseSelfMulticall} from "./BaseSelfMulticall.sol";
import {BaseCallbackReceiver} from "./BaseCallbackReceiver.sol";

/// @title BaseBundler
/// @author Morpho Labs
/// @custom:contact security@morpho.org
/// @notice Enables calling multiple functions in a single call to the same contract (self) as well as calling other
/// Bundler contracts.
/// @dev Every Bundler must inherit from this contract.
/// @dev Every bundler inheriting from this contract must have their external functions payable as they will be
/// delegate called by the `multicall` function (which is payable, and thus might pass a non-null ETH value). It is
/// recommended not to rely on `msg.value` as the same value can be reused for multiple calls.
/// @dev Assumes that any tokens left on the contract can be seized by anyone.
abstract contract BaseBundler is BaseSelfMulticall, BaseCallbackReceiver {
    using SafeCast160 for uint256;
    using SafeTransferLib for ERC20;

    /* IMMUTABLES */

    /// @dev The address of the wrapped native token contract.
    address public immutable WRAPPED_NATIVE;

    /* CONSTRUCTOR */

    /// @dev Warning: assumes the given addresses are non-zero (they are not expected to be deployment arguments).
    constructor(address wNative) {
        WRAPPED_NATIVE = wNative;
    }

    /* EXTERNAL */

    /// @notice Executes a series of calls in a single transaction to self.
    function multicall(uint256 deadline, bytes[] calldata data) external payable lockInitiator {
        require(block.timestamp <= deadline, ErrorsLib.DEADLINE_EXPIRED);

        _multicall(data);
    }

    /* TRANSFER ACTIONS */

    /// @notice Transfers the minimum between the given `amount` and the bundler's balance of `asset` from the bundler
    /// to `recipient`.
    /// @dev Pass in `type(uint256).max` to transfer all.
    function transfer(address asset, address recipient, uint256 amount) external payable {
        require(recipient != address(0), ErrorsLib.ZERO_ADDRESS);
        require(recipient != address(this), ErrorsLib.BUNDLER_ADDRESS);

        amount = Math.min(amount, ERC20(asset).balanceOf(address(this)));

        require(amount != 0, ErrorsLib.ZERO_AMOUNT);

        ERC20(asset).safeTransfer(recipient, amount);
    }

    /// @notice Transfers the minimum between the given `amount` and the bundler's balance of native asset from the
    /// bundler to `recipient`.
    /// @dev Pass in `type(uint256).max` to transfer all.
    function transferNative(address recipient, uint256 amount) external payable {
        require(recipient != address(0), ErrorsLib.ZERO_ADDRESS);
        require(recipient != address(this), ErrorsLib.BUNDLER_ADDRESS);

        amount = Math.min(amount, address(this).balance);

        require(amount != 0, ErrorsLib.ZERO_AMOUNT);

        SafeTransferLib.safeTransferETH(recipient, amount);
    }

    /// @notice Transfers the given `amount` of `asset` from sender to this contract via ERC20 transferFrom.
    /// @notice Warning: should only be called via the bundler's `multicall` function.
    /// @dev Pass in `type(uint256).max` to transfer all.
    function transferFrom(address asset, uint256 amount) external payable {
        amount = Math.min(amount, ERC20(asset).balanceOf(_initiator));

        require(amount != 0, ErrorsLib.ZERO_AMOUNT);

        ERC20(asset).safeTransferFrom(_initiator, address(this), amount);
    }

    /* PERMIT ACTIONS */

    /// @notice Approves the given `amount` of `asset` from sender to be spent by this contract via EIP-2612 Permit with
    /// the given `deadline` & EIP-712 signature's `v`, `r` & `s`.
    /// @notice Warning: should only be called via the bundler's `multicall` function.
    /// @dev Pass `skipRevert == true` to avoid reverting the whole bundle in case the signature expired.
    function permit(address asset, uint256 amount, uint256 deadline, uint8 v, bytes32 r, bytes32 s, bool skipRevert)
        external
        payable
    {
        try IERC20Permit(asset).permit(_initiator, address(this), amount, deadline, v, r, s) {}
        catch (bytes memory returnData) {
            if (!skipRevert) _revert(returnData);
        }
    }

    /* PERMIT2 ACTIONS */

    /// @notice Approves the given `amount` of `asset` from sender to be spent by this contract via Permit2 with the
    /// given `deadline` & EIP-712 `signature`.
    /// @notice Warning: should only be called via the bundler's `multicall` function.
    /// @dev Pass `skipRevert == true` to avoid reverting the whole bundle in case the signature expired.
    function approve2(address asset, uint256 amount, uint256 deadline, Signature calldata signature, bool skipRevert)
        external
        payable
    {
        require(amount != 0, ErrorsLib.ZERO_AMOUNT);

        (,, uint48 nonce) = Permit2Lib.PERMIT2.allowance(_initiator, asset, address(this));

        try Permit2Lib.PERMIT2.permit(
            _initiator,
            IAllowanceTransfer.PermitSingle({
                details: IAllowanceTransfer.PermitDetails({
                    token: asset,
                    amount: amount.toUint160(),
                    // Use an unlimited expiration because it most
                    // closely mimics how a standard approval works.
                    expiration: type(uint48).max,
                    nonce: nonce
                }),
                spender: address(this),
                sigDeadline: deadline
            }),
            bytes.concat(signature.r, signature.s, bytes1(signature.v))
        ) {} catch (bytes memory returnData) {
            if (!skipRevert) _revert(returnData);
        }
    }

    /// @notice Transfers the given `amount` of `asset` from sender to this contract via ERC20 transfer with Permit2.
    /// @notice Warning: should only be called via the bundler's `multicall` function.
    function transferFrom2(address asset, uint256 amount) external payable {
        require(amount != 0, ErrorsLib.ZERO_AMOUNT);

        Permit2Lib.PERMIT2.transferFrom(_initiator, address(this), amount.toUint160(), asset);
    }

    /* ERC4626 ACTIONS */

    /// @notice Mints the given amount of `shares` on the given ERC4626 `vault`, on behalf of `owner`.
    /// @dev Pass in `type(uint256).max` to mint max.
    /// @dev Assumes the given `vault` implements EIP-4626.
    function erc4626Mint(address vault, uint256 shares, address owner) external payable {
        require(owner != address(0), ErrorsLib.ZERO_ADDRESS);

        shares = Math.min(shares, IERC4626(vault).maxMint(owner));

        address asset = IERC4626(vault).asset();
        uint256 assets = Math.min(IERC4626(vault).previewMint(shares), ERC20(asset).balanceOf(address(this)));

        require(assets != 0, ErrorsLib.ZERO_AMOUNT);

        // Approve 0 first to comply with tokens that implement the anti frontrunning approval fix.
        ERC20(asset).safeApprove(vault, 0);
        ERC20(asset).safeApprove(vault, assets);
        IERC4626(vault).mint(shares, owner);
    }

    /// @notice Deposits the given amount of `assets` on the given ERC4626 `vault`, on behalf of `owner`.
    /// @dev Pass in `type(uint256).max` to deposit max.
    /// @dev Assumes the given `vault` implements EIP-4626.
    function erc4626Deposit(address vault, uint256 assets, address owner) external payable {
        require(owner != address(0), ErrorsLib.ZERO_ADDRESS);

        address asset = IERC4626(vault).asset();

        assets = Math.min(assets, IERC4626(vault).maxDeposit(owner));
        assets = Math.min(assets, ERC20(asset).balanceOf(address(this)));

        require(assets != 0, ErrorsLib.ZERO_AMOUNT);

        // Approve 0 first to comply with tokens that implement the anti frontrunning approval fix.
        ERC20(asset).safeApprove(vault, 0);
        ERC20(asset).safeApprove(vault, assets);
        IERC4626(vault).deposit(assets, owner);
    }

    /// @notice Withdraws the given amount of `assets` from the given ERC4626 `vault`, transferring assets to
    /// `receiver`.
    /// @notice Warning: should only be called via the bundler's `multicall` function.
    /// @dev Pass in `type(uint256).max` to withdraw max.
    /// @dev Assumes the given `vault` implements EIP-4626.
    function erc4626Withdraw(address vault, uint256 assets, address receiver) external payable {
        require(receiver != address(0), ErrorsLib.ZERO_ADDRESS);

        assets = Math.min(assets, IERC4626(vault).maxWithdraw(_initiator));

        require(assets != 0, ErrorsLib.ZERO_AMOUNT);

        IERC4626(vault).withdraw(assets, receiver, _initiator);
    }

    /// @notice Redeems the given amount of `shares` from the given ERC4626 `vault`, transferring assets to `receiver`.
    /// @notice Warning: should only be called via the bundler's `multicall` function.
    /// @dev Pass in `type(uint256).max` to redeem max.
    /// @dev Assumes the given `vault` implements EIP-4626.
    function erc4626Redeem(address vault, uint256 shares, address receiver) external payable {
        require(receiver != address(0), ErrorsLib.ZERO_ADDRESS);

        shares = Math.min(shares, IERC4626(vault).maxRedeem(_initiator));

        require(shares != 0, ErrorsLib.ZERO_SHARES);

        IERC4626(vault).redeem(shares, receiver, _initiator);
    }

    /* WRAPPED NATIVE ACTIONS */

    /// @notice Wraps the given `amount` of the native token to wNative.
    /// @notice Warning: should only be called via the bundler's `multicall` function.
    /// @dev Use `BaseBundler.transfer` to transfer the wrapped native tokens to some `receiver`.
    /// @dev Pass in `type(uint256).max` to wrap all.
    function wrapNative(uint256 amount) external payable {
        amount = Math.min(amount, address(this).balance);

        require(amount != 0, ErrorsLib.ZERO_AMOUNT);

        IWNative(WRAPPED_NATIVE).deposit{value: amount}();
    }

    /// @notice Unwraps the given `amount` of wNative to the native token.
    /// @notice Warning: should only be called via the bundler's `multicall` function.
    /// @dev Use `BaseBundler.transferNative` to transfer the unwrapped native tokens to some `receiver`.
    /// @dev Pass in `type(uint256).max` to unwrap all.
    function unwrapNative(uint256 amount) external payable {
        amount = Math.min(amount, ERC20(WRAPPED_NATIVE).balanceOf(address(this)));

        require(amount != 0, ErrorsLib.ZERO_AMOUNT);

        IWNative(WRAPPED_NATIVE).withdraw(amount);
    }

    /* FALLBACKS */

    /// @dev Only the wNative contract is allowed to transfer the native token to this contract, without any calldata.
    receive() external payable virtual {
        require(msg.sender == WRAPPED_NATIVE, ErrorsLib.ONLY_WNATIVE);
    }
}
