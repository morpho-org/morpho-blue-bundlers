// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {ERC20Mock} from "../../../src/mocks/ERC20Mock.sol";

import "./LocalTest.sol";

interface IMetaMorpho {
    function acceptCap(MarketParams memory marketParams) external;
    function setSupplyQueue(Id[] calldata newSupplyQueue) external;
    function submitCap(MarketParams memory marketParams, uint256 newSupplyCap) external;
    function deposit(uint256 assets, address receiver) external returns (uint256 shares);
}

abstract contract VaultTest is LocalTest {
    using MarketParamsLib for MarketParams;

    address internal VAULT_OWNER = makeAddr("VaultOwner");
    IMetaMorpho vault;
    MarketParams idleMarketParams;

    function setUp() public virtual override {
        super.setUp();

        idleMarketParams = MarketParams(address(loanToken), address(0), address(0), address(0), 0);
        vm.startPrank(OWNER);
        morpho.enableLltv(0);
        morpho.createMarket(idleMarketParams);
        vm.stopPrank();

        vault = IMetaMorpho(
            _deploy(
                "lib/metamorpho/out/MetaMorpho.sol/MetaMorpho.json",
                abi.encode(VAULT_OWNER, morpho, 1 days, loanToken, "MetaMorpho Vault", "MMV")
            )
        );
        vm.label(address(vault), "MetaMorpho Vault");
        setCap(marketParams, type(uint184).max);
        setCap(idleMarketParams, type(uint184).max);

        Id[] memory newSupplyQueue = new Id[](1);
        newSupplyQueue[0] = idleMarketParams.id();
        vm.prank(VAULT_OWNER);
        vault.setSupplyQueue(newSupplyQueue);
    }

    function setCap(MarketParams memory marketParams, uint256 newSupplyCap) internal {
        vm.startPrank(VAULT_OWNER);
        vault.submitCap(marketParams, newSupplyCap);
        vm.warp(1 days);
        vault.acceptCap(marketParams);
        vm.stopPrank();
    }

    function convertParams(MarketParams memory marketParams)
        internal
        pure
        returns (PublicAllocatorMarketParams memory mp)
    {
        mp.loanToken = marketParams.loanToken;
        mp.collateralToken = marketParams.collateralToken;
        mp.lltv = marketParams.lltv;
        mp.irm = marketParams.irm;
        mp.oracle = marketParams.oracle;
    }
}
