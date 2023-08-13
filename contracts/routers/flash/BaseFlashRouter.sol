// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.21;

import {IFlashBorrower} from "./interfaces/IFlashBorrower.sol";

import {Errors} from "./libraries/Errors.sol";
import {SafeTransferLib, ERC20} from "@solmate/utils/SafeTransferLib.sol";

import {BaseSelfMulticall} from "../../BaseSelfMulticall.sol";

/// @title BaseFlashRouter.
/// @author Morpho Labs.
/// @custom:contact security@blue.xyz
abstract contract BaseFlashRouter is BaseSelfMulticall {
    using SafeTransferLib for ERC20;

    /* STORAGE */

    /// @dev Keeps track of the bulker's latest batch initiator. Also prevents interacting with the bulker outside of an initiated execution context.
    address internal _initiator;

    /* MODIFIERS */

    modifier lockInitiator() {
        _initiator = msg.sender;

        _;

        delete _initiator;
    }

    /* EXTERNAL */

    function flashLoan(bytes[] calldata data) external lockInitiator returns (bytes[] memory) {
        return _multicall(data);
    }

    /* INTERNAL */

    function _checkInitiated() internal view {
        require(_initiator != address(0), Errors.ALREADY_INITIATED);
    }

    function _onCallback(bytes memory data) internal {
        _checkInitiated();

        bytes[] memory calls = abi.decode(data, (bytes[]));

        if (calls.length == 0) return IFlashBorrower(_initiator).onFlashLoan();

        _multicall(calls);
    }

    /// @dev Gives the max approval to the spender contract to spend the given `asset` if not already approved.
    function _approveMax(address asset, address spender) internal {
        if (ERC20(asset).allowance(address(this), spender) == 0) {
            ERC20(asset).safeApprove(spender, type(uint256).max);
        }
    }
}
