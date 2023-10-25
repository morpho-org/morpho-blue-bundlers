// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {ERC4626Mock} from "../../../src/mocks/ERC4626Mock.sol";
import "../../../src/mocks/bundlers/ERC4626BundlerMock.sol";

import "./helpers/EthereumTest.sol";

contract ERC4626BundlerEthereumTest is EthereumTest {
    using SafeTransferLib for ERC20;

    ERC4626Mock internal vault;

    function setUp() public override {
        super.setUp();

        bundler = new ERC4626BundlerMock();

        vault = new ERC4626Mock(USDT, "USDT Vault", "BV");
    }

    function testErc4626MintUsdtNoReset(uint256 shares) public {
        shares = bound(shares, MIN_AMOUNT, MAX_AMOUNT);

        uint256 assets = vault.previewMint(shares);

        bundle.push(_erc20TransferFrom(USDT, assets));
        bundle.push(_erc4626Mint(address(vault), shares, USER, false));

        vm.prank(address(bundler));
        ERC20(USDT).safeApprove(address(vault), 1);

        deal(USDT, USER, assets);

        vm.prank(USER);
        ERC20(USDT).safeApprove(address(bundler), assets);

        vm.prank(USER);
        vm.expectRevert(bytes("APPROVE_FAILED"));
        bundler.multicall(bundle);
    }

    function testErc4626MintUsdt(uint256 shares) public {
        shares = bound(shares, MIN_AMOUNT, MAX_AMOUNT);

        uint256 assets = vault.previewMint(shares);

        bundle.push(_erc20TransferFrom(USDT, assets));
        bundle.push(_erc4626Mint(address(vault), shares, USER, true));

        vm.prank(address(bundler));
        ERC20(USDT).safeApprove(address(vault), 1);

        deal(USDT, USER, assets);

        vm.startPrank(USER);
        ERC20(USDT).safeApprove(address(bundler), assets);
        bundler.multicall(bundle);
        vm.stopPrank();

        assertEq(ERC20(USDT).balanceOf(address(vault)), assets, "USDT.balanceOf(vault)");
        assertEq(ERC20(USDT).balanceOf(address(bundler)), 0, "USDT.balanceOf(bundler)");
        assertEq(vault.balanceOf(address(bundler)), 0, "vault.balanceOf(USER)");
        assertEq(vault.balanceOf(USER), shares, "vault.balanceOf(USER)");
    }

    function testErc4626DepositUsdtNoReset(uint256 assets) public {
        assets = bound(assets, MIN_AMOUNT, MAX_AMOUNT);

        bundle.push(_erc20TransferFrom(USDT, assets));
        bundle.push(_erc4626Deposit(address(vault), assets, USER, false));

        vm.prank(address(bundler));
        ERC20(USDT).safeApprove(address(vault), 1);

        deal(USDT, USER, assets);

        vm.prank(USER);
        ERC20(USDT).safeApprove(address(bundler), assets);

        vm.prank(USER);
        vm.expectRevert(bytes("APPROVE_FAILED"));
        bundler.multicall(bundle);
    }

    function testErc4626DepositUsdt(uint256 assets) public {
        assets = bound(assets, MIN_AMOUNT, MAX_AMOUNT);

        uint256 shares = vault.previewDeposit(assets);

        bundle.push(_erc20TransferFrom(USDT, assets));
        bundle.push(_erc4626Deposit(address(vault), assets, USER, true));

        vm.prank(address(bundler));
        ERC20(USDT).safeApprove(address(vault), 1);

        deal(USDT, USER, assets);

        vm.startPrank(USER);
        ERC20(USDT).safeApprove(address(bundler), assets);
        bundler.multicall(bundle);
        vm.stopPrank();

        assertEq(ERC20(USDT).balanceOf(address(vault)), assets, "USDT.balanceOf(vault)");
        assertEq(ERC20(USDT).balanceOf(address(bundler)), 0, "USDT.balanceOf(bundler)");
        assertEq(vault.balanceOf(address(bundler)), 0, "vault.balanceOf(USER)");
        assertEq(vault.balanceOf(USER), shares, "vault.balanceOf(USER)");
    }
}
