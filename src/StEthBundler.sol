// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.21;

import {IWStEth} from "./interfaces/IWStEth.sol";
import {IStEth} from "./interfaces/IStEth.sol";

import {Math} from "@morpho-utils/math/Math.sol";
import {ErrorsLib} from "./libraries/ErrorsLib.sol";
import {SafeTransferLib, ERC20} from "solmate/src/utils/SafeTransferLib.sol";

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
    constructor(address stEth, address wstEth) {
        ST_ETH = stEth;
        WST_ETH = wstEth;

        ERC20(ST_ETH).safeApprove(WST_ETH, type(uint256).max);
    }

    /* ACTIONS */

    /// @notice Stakes the given `amount` of ETH via Lido, using the `referral` id.
    /// @dev Use `BaseBundler.erc20Transfer` to transfer the stEth to some `receiver`.
    /// @dev Pass in `type(uint256).max` to stake all.
    function stakeEth(uint256 amount, address referral) external payable {
        amount = Math.min(amount, address(this).balance);

        // Lido will revert with ZERO_DEPOSIT in case amount == 0.
        IStEth(ST_ETH).submit{value: amount}(referral);
    }

    /// @notice Wraps the given `amount` of stETH to wstETH.
    /// @dev Use `BaseBundler.erc20Transfer` to transfer the wrapped stEth to some `receiver`.
    /// @dev Pass in `type(uint256).max` to wrap all.
    function wrapStEth(uint256 amount) external payable {
        amount = Math.min(amount, ERC20(ST_ETH).balanceOf(address(this)));

        require(amount != 0, ErrorsLib.ZERO_AMOUNT);

        IWStEth(WST_ETH).wrap(amount);
    }

    /// @notice Unwraps the given `amount` of wstETH to stETH.
    /// @dev Use `BaseBundler.erc20Transfer` to transfer the unwrapped stEth to some `receiver`.
    /// @dev Pass in `type(uint256).max` to unwrap all.
    function unwrapStEth(uint256 amount) external payable {
        amount = Math.min(amount, ERC20(WST_ETH).balanceOf(address(this)));

        require(amount != 0, ErrorsLib.ZERO_AMOUNT);

        IWStEth(WST_ETH).unwrap(amount);
    }
}
