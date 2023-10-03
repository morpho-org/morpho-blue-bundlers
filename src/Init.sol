// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.21;

import {ErrorsLib} from "./libraries/ErrorsLib.sol";

contract Init {
    /* CONSTANT */

    /// @dev The default value of the initiator is not the address zero to save gas.
    address internal constant UNSET_INITIATOR = address(1);

    /* STORAGE */

    /// @notice Keeps track of the bundler's latest bundle initiator.
    /// @dev Also prevents interacting with the bundler outside of an initiated execution context.
    address private initiator = UNSET_INITIATOR;

    /* PUBLIC */

    /// @dev Specialized getter to prevent using `initiator` directly.
    function getInitiator() public view returns (address) {
        return initiator;
    }

    /* INTERNAL */

    /// @dev To initiate the contract's execution context.
    function _init() internal {
        initiator = msg.sender;
    }

    /// @dev To reset the contract's execution context.
    function _resetInit() internal {
        initiator = UNSET_INITIATOR;
    }

    /// @dev Checks that the contract is in an initiated execution context.
    function _checkInit() internal view {
        require(initiator != UNSET_INITIATOR, ErrorsLib.UNINITIATED);
    }
}
