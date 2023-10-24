// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.21;

import {IWstEth} from "./interfaces/IWstEth.sol";
import {IStEth} from "./interfaces/IStEth.sol";

import {Math} from "../lib/morpho-utils/src/math/Math.sol";
import {ErrorsLib} from "./libraries/ErrorsLib.sol";
import {SafeTransferLib, ERC20} from "../lib/solmate/src/utils/SafeTransferLib.sol";

import {BaseBundler} from "./BaseBundler.sol";

/// @title StEthBundler
/// @author Morpho Labs
/// @custom:contact security@morpho.org
/// @notice Contract allowing to bundle multiple interactions with stETH together.
abstract contract StEthBundler is BaseBundler {
    using SafeTransferLib for ERC20;

    /* IMMUTABLES */

    /// @dev The address of the stETH contract.
    address public immutable ST_ETH;

    /// @dev The address of the wstETH contract.
    address public immutable WST_ETH;

    /* CONSTRUCTOR */

    /// @dev Warning: assumes the given addresses are non-zero (they are not expected to be deployment arguments).
    /// @param stEth The address of the stEth contract.
    /// @param wstEth The address of the wstEth contract.
    constructor(address stEth, address wstEth) {
        ST_ETH = stEth;
        WST_ETH = wstEth;

        ERC20(ST_ETH).safeApprove(WST_ETH, type(uint256).max);
    }

    /* ACTIONS */

    /// @notice Stakes the given `amount` of ETH via Lido, using the `referral` id.
    /// @dev Pass `amount = type(uint256).max` to stake all.
    /// @param amount The amount of ETH to stake.
    /// @param minShares The minimum amount of shares to mint in exchange for `amount`.
    /// @param referral The address of the referral regarding the Lido Rewards-Share Program.
    function stakeEth(uint256 amount, uint256 minShares, address referral) external payable {
        amount = Math.min(amount, address(this).balance);

        // Lido will revert with ZERO_DEPOSIT in case amount == 0.
        uint256 shares = IStEth(ST_ETH).submit{value: amount}(referral);
        require(shares >= minShares, ErrorsLib.SLIPPAGE_EXCEEDED);
    }

    /// @notice Wraps the given `amount` of stETH to wstETH.
    /// @dev Pass `amount = type(uint256).max` to wrap all.
    /// @param amount The amount of stEth to wrap.
    function wrapStEth(uint256 amount) external payable {
        amount = Math.min(amount, ERC20(ST_ETH).balanceOf(address(this)));

        require(amount != 0, ErrorsLib.ZERO_AMOUNT);

        IWstEth(WST_ETH).wrap(amount);
    }

    /// @notice Unwraps the given `amount` of wstETH to stETH.
    /// @dev Pass `amount = type(uint256).max` to unwrap all.
    /// @param amount The amount of wstEth to unwrap.
    function unwrapStEth(uint256 amount) external payable {
        amount = Math.min(amount, ERC20(WST_ETH).balanceOf(address(this)));

        require(amount != 0, ErrorsLib.ZERO_AMOUNT);

        IWstEth(WST_ETH).unwrap(amount);
    }
}
