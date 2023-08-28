// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

interface IUniV2Factory {
    function getPair(address token0, address token1) external returns (address);
}
