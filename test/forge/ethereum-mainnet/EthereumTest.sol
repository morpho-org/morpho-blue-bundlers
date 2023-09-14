// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "../helpers/ForkTest.sol";
import "config/ConfiguredEthereumMainnet.sol";

contract EthereumTest is ConfiguredEthereumMainnet, ForkTest {

    function _network() internal view virtual override(Configured, ConfiguredEthereumMainnet) returns (string memory){
        return ConfiguredEthereumMainnet._network();
    }

    function _loadConfig() internal virtual override(Configured, ConfiguredEthereumMainnet) {
        ConfiguredEthereumMainnet._loadConfig();
    }
}
