// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "../../../../config/Configured.sol";

import "../../helpers/ForkTest.sol";

contract EthereumTest is Configured, ForkTest {
    modifier onlyEthereum() {
        vm.skip(block.chainid != 1);
        _;
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
