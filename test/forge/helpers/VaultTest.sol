// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {ERC20Mock} from "../../../src/mocks/ERC20Mock.sol";
import {MetaMorpho} from "../../../lib/metamorpho/src/MetaMorpho.sol";

import "./LocalTest.sol";

abstract contract VaultTest is LocalTest {
    address internal constant VAULT_OWNER = vm.addr("VaultOwner");
    MetaMorpho vault;
    MarketParams idleMarketParams;

    function setUp() public virtual override {
        super.setUp();

        idleMarketParams = MarketParams(address(loanToken), address(0), address(0), address(0), 0);
        vm.prank(OWNER);
        morpho.createMarket(idleMarketParams);

        vault = new MetaMorpho(VAULT_OWNER, address(morpho), 1 days, address(loanToken), "MetaMorpho Vault", "MMV");
        _setCap(marketParams, type(uint184).max);
        _setCap(idleMarketParams, type(uint184).max);

        Id[] memory newSupplyQueue = Id[](1);
        newSupplyQueue[0] = idleMarketParams.id();
        vm.prank(VAULT_OWNER);
        vault.setSupplyQueue(newSupplyQueue);
    }

    function setCap(MarketParams marketParams, uint256 newSupplyCap) internal {
        vm.startPrank(VAULT_OWNER);
        vault.submitCap(marketParams, newSupplyCap);
        vm.warp(1 days);
        vault.acceptCap(marketParams);
        vm.stopPrank();
    }
}
