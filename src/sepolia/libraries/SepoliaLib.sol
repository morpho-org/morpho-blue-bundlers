// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

library SepoliaLib {
    /// @dev The address of the WETH contract on Sepolia.
    address internal constant WETH = 0x7b79995e5f793A07Bc00c21412e50Ecae098E7f9;

    /// @dev The address of the wstETH contract on Sepolia.
    /// @dev The wstETH contract corresponds exactly to the one on Ethereum. The underlying stETH contract is a mock
    /// exposing a subset of the interface of stETH on Ethereum and behaves just like WETH: no reward is accrued.
    address internal constant WST_ETH = 0xA0dc0A387a022d8F33d2BE6fF139077639B1a348;
}
