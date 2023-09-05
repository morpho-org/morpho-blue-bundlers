// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.21;

import {ErrorsLib} from "./libraries/ErrorsLib.sol";
import {Math} from "@morpho-utils/math/Math.sol";
import {SafeTransferLib, ERC20} from "solmate/src/utils/SafeTransferLib.sol";

import {BaseSelfMulticall} from "./BaseSelfMulticall.sol";
import {BaseCallbackReceiver} from "./BaseCallbackReceiver.sol";

/// @title BaseBundler
/// @author Morpho Labs
/// @custom:contact security@morpho.xyz
/// @notice Enables calling multiple functions in a single call to the same contract (self) as well as calling other
/// Bundler contracts.
/// @dev Every Bundler must inherit from this contract.
abstract contract BaseBundler is BaseSelfMulticall, BaseCallbackReceiver {
    using SafeTransferLib for ERC20;

    /* EXTERNAL */

    /// @notice Executes a series of calls in a single transaction to self.
    function multicall(uint256 deadline, bytes[] calldata data)
        external
        payable
        lockInitiator
        returns (bytes[] memory)
    {
        require(block.timestamp <= deadline, ErrorsLib.DEADLINE_EXPIRED);

        return _multicall(data);
    }

    /// @dev Transfers the minimum between the given `amount` and the bundler balance of `asset` from this contract to
    /// `recipient`.
    function transfer(address asset, address recipient, uint256 amount) external payable {
        require(recipient != address(0), ErrorsLib.ZERO_ADDRESS);
        require(recipient != address(this), ErrorsLib.BUNDLER_ADDRESS);

        amount = Math.min(amount, ERC20(asset).balanceOf(address(this)));

        require(amount != 0, ErrorsLib.ZERO_AMOUNT);

        ERC20(asset).safeTransfer(recipient, amount);
    }

    function transferNativeToken(address recipient, uint256 amount) external payable {
        require(recipient != address(0), ErrorsLib.ZERO_ADDRESS);
        require(recipient != address(this), ErrorsLib.BUNDLER_ADDRESS);

        amount = Math.min(amount, address(this).balance);

        require(amount != 0, ErrorsLib.ZERO_AMOUNT);

        SafeTransferLib.safeTransferETH(recipient, amount);
    }
}
