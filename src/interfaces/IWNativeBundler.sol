// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

interface IWNativeBundler {
    function wrapNative(uint256 amount) external;
    function unwrapNative(uint256 amount) external;
}
