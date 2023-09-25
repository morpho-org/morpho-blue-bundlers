// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.21;

import {Signature} from "@morpho-blue/interfaces/IMorpho.sol";
import {IAllowanceTransfer} from "@permit2/interfaces/IAllowanceTransfer.sol";

import {ErrorsLib} from "./libraries/ErrorsLib.sol";
import {SafeCast160} from "@permit2/libraries/SafeCast160.sol";
import {ERC20, Permit2Lib} from "@permit2/libraries/Permit2Lib.sol";
import {ConditionalCallLib} from "./libraries/ConditionalCallLib.sol";

import {BaseBundler} from "./BaseBundler.sol";

/// @dev Permit2 interface exposing one single `permit` function version to avoid issues when querying the function
/// pointer.
interface IPermit2Internal {
    function permit(address owner, IAllowanceTransfer.PermitSingle memory permitSingle, bytes calldata signature)
        external;
}

/// @title Permit2Bundler
/// @author Morpho Labs
/// @custom:contact security@morpho.xyz
/// @notice Bundler contract managing interactions with ERC20 compliant tokens.
/// @dev It leverages Uniswap's Permit2 contract.
abstract contract Permit2Bundler is BaseBundler {
    using SafeCast160 for uint256;
    using ConditionalCallLib for address;

    /* ACTIONS */

    /// @notice Approves the given `amount` of `asset` from sender to be spent by this contract via Permit2 with the
    /// given `deadline` & EIP-712 `signature`.
    /// @notice Warning: should only be called via the bundler's `multicall` function.
    function approve2(address asset, uint256 amount, uint256 deadline, Signature calldata signature, bool allowRevert)
        external
        payable
    {
        require(amount != 0, ErrorsLib.ZERO_AMOUNT);

        (,, uint48 nonce) = Permit2Lib.PERMIT2.allowance(_initiator, asset, address(this));

        address(Permit2Lib.PERMIT2).conditionalCall(
            abi.encodeCall(
                IPermit2Internal(address(Permit2Lib.PERMIT2)).permit,
                (
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
                )
            ),
            allowRevert
        );
    }

    /// @notice Transfers the given `amount` of `asset` from sender to this contract via ERC20 transfer with Permit2.
    /// @notice Warning: should only be called via the bundler's `multicall` function.
    function transferFrom2(address asset, uint256 amount) external payable {
        require(amount != 0, ErrorsLib.ZERO_AMOUNT);

        Permit2Lib.PERMIT2.transferFrom(_initiator, address(this), amount.toUint160(), asset);
    }
}
