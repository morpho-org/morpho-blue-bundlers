// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.21;

import {EVMBundler} from "../EVMBundler.sol";
import {StEthBundler} from "./StEthBundler.sol";
import {WNativeBundler} from "../WNativeBundler.sol";

/// @title EthereumBundler
/// @author Morpho Labs
/// @custom:contact security@morpho.xyz
/// @notice Bundler contract specific to the Ethereum mainnet.
contract EthereumBundler is EVMBundler, WNativeBundler, StEthBundler {
    /* CONSTANTS */

    /// @dev The address of the WETH contract on Ethereum mainnet.
    address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    /* CONSTRUCTOR */

    constructor(address morpho) EVMBundler(morpho) WNativeBundler(WETH) {}
}
