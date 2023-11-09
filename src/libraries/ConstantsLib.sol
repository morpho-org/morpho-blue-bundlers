// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

/// @dev The default value of the initiator of the multicall transaction is not the address zero to save gas.
address constant UNSET_INITIATOR = address(1);
