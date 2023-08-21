// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.5.0;

interface IMulticall {
    function multicall(bytes[] calldata data) external payable returns (bytes[] memory results);
}
