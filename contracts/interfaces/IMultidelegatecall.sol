// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.6.2;

struct Call {
    bytes data;
    bool allowRevert;
}

interface IMultidelegatecall {
    function multicall(uint256 deadline, Call[] calldata data) external payable returns (bytes[] memory);
}
