// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.21;

import {IWETH} from "./interfaces/IWETH.sol";

import {Math} from "@morpho-utils/math/Math.sol";
import {ErrorsLib} from "./libraries/ErrorsLib.sol";
import {SafeTransferLib, ERC20} from "solmate/src/utils/SafeTransferLib.sol";

import {BaseBundler} from "./BaseBundler.sol";

/// @title WETHBundler
/// @author Morpho Labs
/// @custom:contact security@morpho.org
/// @notice Bundler contract managing interactions with WETH.
abstract contract WETHBundler is BaseBundler {
    using SafeTransferLib for ERC20;

    /* IMMUTABLES */

    /// @dev The address of the WETH token contract.
    address public immutable WETH_TOKEN;

    /* CONSTRUCTOR */

    /// @dev Warning: assumes the given addresses are non-zero (they are not expected to be deployment arguments).
    constructor(address wEth) {
        WETH_TOKEN = wEth;
    }

    /* FALLBACKS */

    /// @dev Only the WETH contract is allowed to transfer ETH to this contract, without any calldata.
    receive() external payable virtual {
        require(msg.sender == WETH_TOKEN, ErrorsLib.ONLY_WETH);
    }

    /* ACTIONS */

    /// @notice Wraps the given `amount` of ETH to WETH.
    /// @notice Warning: should only be called via the bundler's `multicall` function.
    /// @dev Use `BaseBundler.erc20Transfer` to transfer the WETH to some `receiver`.
    /// @dev Pass `amount = type(uint256).max` to wrap all.
    function wrapETH(uint256 amount) external payable {
        amount = Math.min(amount, address(this).balance);

        require(amount != 0, ErrorsLib.ZERO_AMOUNT);

        IWETH(WETH_TOKEN).deposit{value: amount}();
    }

    /// @notice Unwraps the given `amount` of WETH to ETH.
    /// @notice Warning: should only be called via the bundler's `multicall` function.
    /// @dev Use `BaseBundler.nativeTransfer` to transfer the ETH to some `receiver`.
    /// @dev Pass `amount = type(uint256).max` to unwrap all.
    function unwrapETH(uint256 amount) external payable {
        amount = Math.min(amount, ERC20(WETH_TOKEN).balanceOf(address(this)));

        require(amount != 0, ErrorsLib.ZERO_AMOUNT);

        IWETH(WETH_TOKEN).withdraw(amount);
    }
}
