// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.21;

import {IMultidelegatecall, Call} from "./interfaces/IMultidelegatecall.sol";

import {ErrorsLib} from "./libraries/ErrorsLib.sol";

/// @title Multidelegatecall
/// @author Morpho Labs
/// @custom:contact security@morpho.org
/// @notice Enables calling multiple functions in a single call to the same contract (self).
/// @dev Based on Uniswap work: https://github.com/Uniswap/v3-periphery/blob/main/contracts/base/Multicall.sol
abstract contract Multidelegatecall is IMultidelegatecall {
    /* EXTERNAL */

    /// @notice Executes a series of calls in a single transaction to self.
    function multicall(uint256 deadline, Call[] calldata calls) public payable virtual returns (bytes[] memory) {
        require(block.timestamp <= deadline, ErrorsLib.DEADLINE_EXPIRED);

        return _multicall(calls);
    }

    /* INTERNAL */

    /// @notice Executes a series of delegate calls to the contract itself.
    function _multicall(Call[] memory calls) internal returns (bytes[] memory results) {
        uint256 nbCalls = calls.length;

        results = new bytes[](nbCalls);

        for (uint256 i; i < nbCalls; ++i) {
            Call memory call = calls[i];

            (bool success, bytes memory result) = address(this).delegatecall(call.data);

            if (!success && !call.allowRevert) {
                if (result.length < 68) revert();

                assembly {
                    result := add(result, 0x04)
                }

                revert(abi.decode(result, (string)));
            }

            results[i] = result;
        }
    }
}
