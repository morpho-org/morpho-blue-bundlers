// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.21;

import {IBundlerGateway} from "./interfaces/IBundlerGateway.sol";
import {IMulticall} from "./interfaces/IMulticall.sol";

import {ErrorsLib} from "./libraries/ErrorsLib.sol";

contract BundlerGateway is IBundlerGateway {
    address public initiator;

    /// @notice Executes multiple actions on another `bundler` contract passing along the required `data`.
    function callBundler(address bundler, uint256 deadline, bytes[] calldata data) external {
        require(bundler != address(0), ErrorsLib.ZERO_ADDRESS);
        require(block.timestamp <= deadline, ErrorsLib.DEADLINE_EXPIRED);

        bool isTopCall = initiator == address(0);

        if (isTopCall) initiator = msg.sender;
        IMulticall(bundler).multicall(data);
        if (isTopCall) delete initiator;
    }
}
