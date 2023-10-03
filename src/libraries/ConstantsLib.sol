// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

/// @dev The address of the Permit2 contract on all chains.
address constant PERMIT2 = 0x000000000022D473030F116dDEE9F6B43aC78BA3;

/// @dev The default value of the initiator of the multicall transaction is not the address zero to save gas.
address constant UNSET_INITIATOR = address(1);
