// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.21;

import {Signature} from "@morpho-blue/interfaces/IMorpho.sol";

import {Errors} from "./libraries/Errors.sol";
import {Math} from "@morpho-utils/math/Math.sol";
import {SafeTransferLib, ERC20} from "@solmate/utils/SafeTransferLib.sol";
import {ERC20 as ERC20Permit2, Permit2Lib} from "@permit2/libraries/Permit2Lib.sol";

import {BaseBundler} from "./BaseBundler.sol";

/// @title ERC20Bundler.
/// @author Morpho Labs.
/// @custom:contact security@blue.xyz
abstract contract ERC20Bundler is BaseBundler {
    using Permit2Lib for ERC20Permit2;
    using SafeTransferLib for ERC20;

    /* ACTIONS */

    /// @dev Transfers the minimum between the given `amount` and the bundler balance of `asset` from this contract to `recipient`.
    function transfer(address asset, address recipient, uint256 amount) external {
        require(recipient != address(0), Errors.ZERO_ADDRESS);
        require(recipient != address(this), Errors.BUNDLER_ADDRESS);

        amount = Math.min(amount, ERC20(asset).balanceOf(address(this)));

        require(amount != 0, Errors.ZERO_AMOUNT);

        ERC20(asset).safeTransfer(recipient, amount);
    }

    /// @dev Approves the given `amount` of `asset` from sender to be spent by this contract via Permit2 with the given `deadline` & EIP712 `signature`.
    function approve2(address asset, uint256 amount, uint256 deadline, Signature calldata signature) external {
        require(amount != 0, Errors.ZERO_AMOUNT);

        ERC20Permit2(asset).simplePermit2(
            _initiator, address(this), amount, deadline, signature.v, signature.r, signature.s
        );
    }

    /// @dev Transfers the given `amount` of `asset` from sender to this contract via ERC20 transfer with Permit2 fallback.
    function transferFrom2(address asset, uint256 amount) external {
        require(amount != 0, Errors.ZERO_AMOUNT);

        ERC20Permit2(asset).transferFrom2(_initiator, address(this), amount);
    }
}
