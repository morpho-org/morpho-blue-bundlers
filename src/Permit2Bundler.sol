// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.21;

import {ISignatureTransfer} from "../lib/permit2/src/interfaces/ISignatureTransfer.sol";

import "./libraries/ConstantsLib.sol";
import {ErrorsLib} from "./libraries/ErrorsLib.sol";
import {Math} from "../lib/morpho-utils/src/math/Math.sol";
import {ERC20} from "../lib/solmate/src/tokens/ERC20.sol";

import {BaseBundler} from "./BaseBundler.sol";

/// @title Permit2Bundler
/// @author Morpho Labs
/// @custom:contact security@morpho.xyz
/// @notice Bundler contract managing interactions with ERC20 tokens and Permit2.
abstract contract Permit2Bundler is BaseBundler {
    /* ACTIONS */

    /// @notice Permits and performs a transfer from the initiator to the recipient via Permit2.
    /// @dev Pass `permit.permitted.amount = type(uint256).max` to transfer all.
    function permit2TransferFrom(ISignatureTransfer.PermitTransferFrom memory permit, bytes memory signature)
        external
        payable
        onlyInitiated
    {
        address initiator = initiator();
        uint256 amount = Math.min(permit.permitted.amount, ERC20(permit.permitted.token).balanceOf(initiator));

        require(amount != 0, ErrorsLib.ZERO_AMOUNT);

        ISignatureTransfer.SignatureTransferDetails memory transferDetails =
            ISignatureTransfer.SignatureTransferDetails({to: address(this), requestedAmount: amount});

        ISignatureTransfer(PERMIT2).permitTransferFrom(permit, transferDetails, initiator, signature);
    }
}
