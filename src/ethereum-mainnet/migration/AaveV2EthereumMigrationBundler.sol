// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.21;

import {MainnetLib} from "../libraries/MainnetLib.sol";

import {EthereumStEthBundler} from "../EthereumStEthBundler.sol";
import {AaveV2MigrationBundler} from "../../migration/AaveV2MigrationBundler.sol";

/// @title AaveV2EthereumMigrationBundler
/// @author Morpho Labs
/// @custom:contact security@morpho.org
/// @notice Contract allowing to migrate a position from Aave V2 on Ethereum mainnet to Morpho Blue easily.
contract AaveV2EthereumMigrationBundler is EthereumStEthBundler, AaveV2MigrationBundler {
    /* CONSTRUCTOR */

    constructor(address morpho) AaveV2MigrationBundler(morpho, MainnetLib.WETH, MainnetLib.AAVE_V2_POOL) {}
}
