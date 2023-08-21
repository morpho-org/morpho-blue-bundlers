// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.5.0;

interface IBundlerGateway {
    function initiator() external view returns (address);
    function callBundler(address bundler, uint256 deadline, bytes[] calldata data) external;
}
