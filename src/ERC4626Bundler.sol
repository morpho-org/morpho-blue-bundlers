// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.21;

import {IERC4626} from "../lib/openzeppelin-contracts/contracts/interfaces/IERC4626.sol";

import {Math} from "../lib/morpho-utils/src/math/Math.sol";
import {ErrorsLib} from "./libraries/ErrorsLib.sol";
import {SafeERC20, IERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";

import {BaseBundler} from "./BaseBundler.sol";

/// @title ERC4626Bundler
/// @author Morpho Labs
/// @custom:contact security@morpho.org
/// @notice Bundler contract managing interactions with ERC4626 compliant tokens.
abstract contract ERC4626Bundler is BaseBundler {
    using SafeERC20 for IERC20;

    /* ACTIONS */

    /// @notice Mints the given amount of `shares` on the given ERC4626 `vault`, on behalf of `owner`.
    /// @dev Pass `type(uint256).max` as `shares` to mint max.
    /// @dev Assumes the given `vault` implements EIP-4626.
    function erc4626Mint(address vault, uint256 shares, address owner) external payable {
        require(owner != address(0), ErrorsLib.ZERO_ADDRESS);
        /// Do not check `owner != address(this)` to allow the bundler to receive the vault's shares.

        shares = Math.min(shares, IERC4626(vault).maxMint(owner));

        address asset = IERC4626(vault).asset();
        uint256 assets = Math.min(IERC4626(vault).previewMint(shares), IERC20(asset).balanceOf(address(this)));

        require(assets != 0, ErrorsLib.ZERO_AMOUNT);

        IERC20(asset).forceApprove(vault, assets);
        IERC4626(vault).mint(shares, owner);
    }

    /// @notice Deposits the given amount of `assets` on the given ERC4626 `vault`, on behalf of `owner`.
    /// @dev Pass `type(uint256).max` as `assets` to deposit max.
    /// @dev Assumes the given `vault` implements EIP-4626.
    function erc4626Deposit(address vault, uint256 assets, address owner) external payable {
        require(owner != address(0), ErrorsLib.ZERO_ADDRESS);
        /// Do not check `owner != address(this)` to allow the bundler to receive the vault's shares.

        address asset = IERC4626(vault).asset();

        assets = Math.min(assets, IERC4626(vault).maxDeposit(owner));
        assets = Math.min(assets, IERC20(asset).balanceOf(address(this)));

        require(assets != 0, ErrorsLib.ZERO_AMOUNT);

        IERC20(asset).forceApprove(vault, assets);
        IERC4626(vault).deposit(assets, owner);
    }

    /// @notice Withdraws the given amount of `assets` from the given ERC4626 `vault`, transferring assets to
    /// `receiver`.
    /// @notice Warning: should only be called via the bundler's `multicall` function.
    /// @dev Pass `type(uint256).max` as `assets` to withdraw max.
    /// @dev Assumes the given `vault` implements EIP-4626.
    function erc4626Withdraw(address vault, uint256 assets, address receiver) external payable {
        require(receiver != address(0), ErrorsLib.ZERO_ADDRESS);
        /// Do not check `receiver != address(this)` to allow the bundler to receive the underlying asset.

        address initiator = initiator();

        assets = Math.min(assets, IERC4626(vault).maxWithdraw(initiator));

        require(assets != 0, ErrorsLib.ZERO_AMOUNT);

        IERC4626(vault).withdraw(assets, receiver, initiator);
    }

    /// @notice Redeems the given amount of `shares` from the given ERC4626 `vault`, transferring assets to `receiver`.
    /// @notice Warning: should only be called via the bundler's `multicall` function.
    /// @dev Pass `type(uint256).max` as `shares` to redeem max.
    /// @dev Assumes the given `vault` implements EIP-4626.
    function erc4626Redeem(address vault, uint256 shares, address receiver) external payable {
        require(receiver != address(0), ErrorsLib.ZERO_ADDRESS);
        /// Do not check `receiver != address(this)` to allow the bundler to receive the underlying asset.

        address initiator = initiator();

        shares = Math.min(shares, IERC4626(vault).maxRedeem(initiator));

        require(shares != 0, ErrorsLib.ZERO_SHARES);

        IERC4626(vault).redeem(shares, receiver, initiator);
    }
}
