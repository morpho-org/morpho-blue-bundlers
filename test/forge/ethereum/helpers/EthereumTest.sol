// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "config/ConfiguredEthereum.sol";

import "../../helpers/ForkTest.sol";

contract EthereumTest is ConfiguredEthereum, ForkTest {
    function _network() internal view virtual override(Configured, ConfiguredEthereum) returns (string memory) {
        return ConfiguredEthereum._network();
    }

    function _loadConfig() internal virtual override(Configured, ConfiguredEthereum) {
        ConfiguredEthereum._loadConfig();
    }

    function deal(address asset, address recipient, uint256 amount) internal virtual override {
        if (asset == ST_ETH) {
            if (amount == 0) return;

            deal(recipient, amount);

            vm.prank(recipient);
            uint256 stEthAmount = IStEth(ST_ETH).submit{value: amount}(address(0));

            vm.assume(stEthAmount != 0);

            return;
        }

        return super.deal(asset, recipient, amount);
    }
}
