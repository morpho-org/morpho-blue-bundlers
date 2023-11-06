// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.21;

import {MainnetLib} from "../libraries/MainnetLib.sol";

import {BaseBundler} from "../../BaseBundler.sol";
import {EthereumStEthBundler} from "../EthereumStEthBundler.sol";
import {MigrationBundler} from "../../migration/MigrationBundler.sol";
import {AaveV2MigrationBundler} from "../../migration/AaveV2MigrationBundler.sol";

/// @title AaveV2EthereumMigrationBundler
/// @author Morpho Labs
/// @custom:contact security@morpho.org
/// @notice Contract allowing to migrate a position from Aave V2 on Ethereum to Morpho Blue easily.
contract AaveV2EthereumMigrationBundler is EthereumStEthBundler, AaveV2MigrationBundler {
    /* CONSTRUCTOR */

    constructor(address morpho) AaveV2MigrationBundler(morpho, MainnetLib.AAVE_V2_POOL) {}

    /* INTERNAL */

    /// @inheritdoc MigrationBundler
    function _isSenderAuthorized() internal view override(BaseBundler, MigrationBundler) returns (bool) {
        return MigrationBundler._isSenderAuthorized();
    }
}
