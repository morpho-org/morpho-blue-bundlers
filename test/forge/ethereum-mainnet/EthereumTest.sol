// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "../helpers/ForkTest.sol";
import "config/ConfiguredEthereum.sol";

contract EthereumTest is ConfiguredEthereum, ForkTest {
    function _network() internal view virtual override(Configured, ConfiguredEthereum) returns (string memory) {
        return ConfiguredEthereum._network();
    }

    function _loadConfig() internal virtual override(Configured, ConfiguredEthereum) {
        ConfiguredEthereum._loadConfig();
    }
}
