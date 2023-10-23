// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

interface ICompoundV2MigrationBundler {
    function compoundV2Repay(address cToken, uint256 amount) external payable;
    function compoundV2Redeem(address cToken, uint256 amount) external payable;
}
