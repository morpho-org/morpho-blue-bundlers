// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.21;

import {MainnetLib} from "./libraries/MainnetLib.sol";

import {TransferBundler} from "../TransferBundler.sol";
import {EthereumPermitBundler} from "./EthereumPermitBundler.sol";
import {Permit2Bundler} from "../Permit2Bundler.sol";
import {ERC4626Bundler} from "../ERC4626Bundler.sol";
import {WETHBundler} from "../WETHBundler.sol";
import {EthereumStEthBundler} from "./EthereumStEthBundler.sol";
import {UrdBundler} from "../UrdBundler.sol";
import {MorphoBundler} from "../MorphoBundler.sol";

/// @title EthereumBundler
/// @author Morpho Labs
/// @custom:contact security@morpho.org
/// @notice Bundler contract specific to Ethereum.
contract EthereumBundler is
    TransferBundler,
    EthereumPermitBundler,
    Permit2Bundler,
    ERC4626Bundler,
    WETHBundler,
    EthereumStEthBundler,
    UrdBundler,
    MorphoBundler
{
    /* CONSTRUCTOR */

    constructor(address morpho) WETHBundler(MainnetLib.WETH) MorphoBundler(morpho) {}
}
