// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.21;

import {ERC4626Bundler} from "../ERC4626Bundler.sol";
import {WNativeBundler} from "../WNativeBundler.sol";
import {StEthBundler} from "./StEthBundler.sol";

/// @title EthereumWrapperBundler.
/// @author Morpho Labs.
/// @custom:contact security@blue.xyz
contract EthereumWrapperBundler is ERC4626Bundler, WNativeBundler, StEthBundler {
    address private constant _WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    constructor() WNativeBundler(_WETH) {}
}
