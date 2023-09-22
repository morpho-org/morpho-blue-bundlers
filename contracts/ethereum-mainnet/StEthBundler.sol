// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.21;

import {IWStEth} from "./interfaces/IWStEth.sol";
import {IStEth} from "./interfaces/IStEth.sol";

import {ErrorsLib} from "../libraries/ErrorsLib.sol";
import {Math} from "@morpho-utils/math/Math.sol";
import {SafeTransferLib, ERC20} from "solmate/src/utils/SafeTransferLib.sol";

import {BaseBundler} from "../BaseBundler.sol";

/// @title StEthBundler
/// @author Morpho Labs
/// @custom:contact security@morpho.org
/// @notice Contract allowing to bundle multiple interactions with stETH together.
abstract contract StEthBundler is BaseBundler {
    using SafeTransferLib for ERC20;

    /* CONSTANTS */

    /// @dev The address of the stETH contract on Ethereum mainnet.
    address public constant ST_ETH = 0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84;

    /// @dev The address of the wstETH contract on Ethereum mainnet.
    address public constant WST_ETH = 0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0;

    /* CONSTRUCTOR */

    constructor() {
        ERC20(ST_ETH).safeApprove(WST_ETH, type(uint256).max);
    }

    /* ACTIONS */

    function stakeEth(uint256 amount, address referral) external payable {
        amount = Math.min(amount, address(this).balance);

        // Lido will revert with ZERO_DEPOSIT in case amount == 0.
        IStEth(ST_ETH).submit{value: amount}(referral);
    }

    /// @notice Wraps the given `amount` of stETH to wstETH and transfers it to `receiver`.
    /// @dev Use `BaseBundler.transfer` to transfer the wrapped stEth to some `receiver`.
    function wrapStEth(uint256 amount) external payable {
        amount = Math.min(amount, ERC20(ST_ETH).balanceOf(address(this)));

        require(amount != 0, ErrorsLib.ZERO_AMOUNT);

        IWStEth(WST_ETH).wrap(amount);
    }

    /// @notice Unwraps the given `amount` of wstETH to stETH and transfers it to `receiver`.
    /// @dev Use `BaseBundler.transfer` to transfer the unwrapped stEth to some `receiver`.
    function unwrapStEth(uint256 amount) external payable {
        amount = Math.min(amount, ERC20(WST_ETH).balanceOf(address(this)));

        require(amount != 0, ErrorsLib.ZERO_AMOUNT);

        IWStEth(WST_ETH).unwrap(amount);
    }
}
