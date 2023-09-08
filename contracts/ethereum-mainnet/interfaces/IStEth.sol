// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.5.0;

interface IStEth {
    function transferShares(address _recipient, uint256 _sharesAmount) external returns (uint256);

    function transferSharesFrom(address _sender, address _recipient, uint256 _sharesAmount) external returns (uint256);

    function getPooledEthByShares(uint256 _sharesAmount) external view returns (uint256);

    function getSharesByPooledEth(uint256 _stEthAmount) external view returns (uint256);

    function getCurrentStakeLimit() external view returns (uint256);

    function submit(address _referral) external payable returns (uint256);
}
