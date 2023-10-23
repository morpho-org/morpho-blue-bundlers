// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {ErrorsLib} from "../../src/libraries/ErrorsLib.sol";

import {ERC4626Mock} from "../../src/mocks/ERC4626Mock.sol";
import "../../src/mocks/bundlers/ERC4626BundlerMock.sol";

import "./helpers/LocalTest.sol";

contract ERC4626BundlerLocalTest is LocalTest {
    ERC4626Mock internal vault;

    function setUp() public override {
        super.setUp();

        bundler = new ERC4626BundlerMock();

        vault = new ERC4626Mock(address(loanToken), "LoanToken Vault", "BV");
    }

    function testErc4626MintZeroAdressVault(uint256 shares) public {
        bundle.push(_erc4626Mint(address(0), shares, RECEIVER));

        vm.expectRevert();
        bundler.multicall(bundle);
    }

    function testErc4626MintZeroAdress(uint256 shares) public {
        bundle.push(_erc4626Mint(address(vault), shares, address(0)));

        vm.expectRevert(bytes(ErrorsLib.ZERO_ADDRESS));
        bundler.multicall(bundle);
    }

    function testErc4626DepositZeroAdressVault(uint256 assets) public {
        bundle.push(_erc4626Deposit(address(0), assets, RECEIVER));

        vm.expectRevert();
        bundler.multicall(bundle);
    }

    function testErc4626DepositZeroAdress(uint256 assets) public {
        bundle.push(_erc4626Deposit(address(vault), assets, address(0)));

        vm.expectRevert(bytes(ErrorsLib.ZERO_ADDRESS));
        bundler.multicall(bundle);
    }

    function test4626DepositUninitiated(uint256 assets) public {
        vm.expectRevert(bytes(ErrorsLib.UNINITIATED));
        ERC4626BundlerMock(address(bundler)).erc4626Withdraw(address(vault), assets, RECEIVER);
    }

    function testErc4626WithdrawZeroAdressVault(uint256 assets) public {
        bundle.push(_erc4626Withdraw(address(0), assets, RECEIVER));

        vm.expectRevert();
        bundler.multicall(bundle);
    }

    function testErc4626WithdrawZeroAdress(uint256 assets) public {
        bundle.push(_erc4626Withdraw(address(vault), assets, address(0)));

        vm.expectRevert(bytes(ErrorsLib.ZERO_ADDRESS));
        bundler.multicall(bundle);
    }

    function test4626RedeemUninitiated(uint256 assets) public {
        vm.expectRevert(bytes(ErrorsLib.UNINITIATED));
        ERC4626BundlerMock(address(bundler)).erc4626Redeem(address(vault), assets, RECEIVER);
    }

    function testErc4626RedeemZeroAdressVault(uint256 assets) public {
        bundle.push(_erc4626Redeem(address(0), assets, RECEIVER));

        vm.expectRevert();
        bundler.multicall(bundle);
    }

    function testErc4626RedeemZeroAdress(uint256 shares) public {
        bundle.push(_erc4626Redeem(address(vault), shares, address(0)));

        vm.expectRevert(bytes(ErrorsLib.ZERO_ADDRESS));
        bundler.multicall(bundle);
    }

    function testErc4626MintZero() public {
        bundle.push(_erc4626Mint(address(vault), 0, RECEIVER));

        vm.expectRevert(bytes(ErrorsLib.ZERO_AMOUNT));
        bundler.multicall(bundle);
    }

    function testErc4626DepositZero() public {
        bundle.push(_erc4626Deposit(address(vault), 0, RECEIVER));

        vm.expectRevert(bytes(ErrorsLib.ZERO_AMOUNT));
        bundler.multicall(bundle);
    }

    function testErc4626WithdrawZero() public {
        bundle.push(_erc4626Withdraw(address(vault), 0, RECEIVER));

        vm.expectRevert(bytes(ErrorsLib.ZERO_AMOUNT));
        bundler.multicall(bundle);
    }

    function testErc4626RedeemZero() public {
        bundle.push(_erc4626Redeem(address(vault), 0, RECEIVER));

        vm.expectRevert(bytes(ErrorsLib.ZERO_SHARES));
        bundler.multicall(bundle);
    }

    function testErc4626Mint(uint256 shares) public {
        shares = bound(shares, MIN_AMOUNT, MAX_AMOUNT);

        uint256 assets = vault.previewMint(shares);

        bundle.push(_erc20TransferFrom(address(loanToken), assets));
        bundle.push(_erc4626Mint(address(vault), shares, USER));

        loanToken.setBalance(USER, assets);

        vm.startPrank(USER);
        loanToken.approve(address(bundler), assets);
        bundler.multicall(bundle);
        vm.stopPrank();

        assertEq(loanToken.balanceOf(address(vault)), assets, "loan.balanceOf(vault)");
        assertEq(loanToken.balanceOf(address(bundler)), 0, "loan.balanceOf(bundler)");
        assertEq(vault.balanceOf(address(bundler)), 0, "vault.balanceOf(USER)");
        assertEq(vault.balanceOf(USER), shares, "vault.balanceOf(USER)");
    }

    function testErc4626Deposit(uint256 assets) public {
        assets = bound(assets, MIN_AMOUNT, MAX_AMOUNT);

        uint256 shares = vault.previewDeposit(assets);

        bundle.push(_erc20TransferFrom(address(loanToken), assets));
        bundle.push(_erc4626Deposit(address(vault), assets, USER));

        loanToken.setBalance(USER, assets);

        vm.startPrank(USER);
        loanToken.approve(address(bundler), assets);
        bundler.multicall(bundle);
        vm.stopPrank();

        assertEq(loanToken.balanceOf(address(vault)), assets, "loan.balanceOf(vault)");
        assertEq(loanToken.balanceOf(address(bundler)), 0, "loan.balanceOf(bundler)");
        assertEq(vault.balanceOf(address(bundler)), 0, "vault.balanceOf(USER)");
        assertEq(vault.balanceOf(USER), shares, "vault.balanceOf(USER)");
    }

    function testErc4626Withdraw(uint256 deposited, uint256 assets) public {
        deposited = bound(deposited, MIN_AMOUNT, MAX_AMOUNT);

        uint256 minted = _depositVault(deposited);

        assets = bound(assets, MIN_AMOUNT, deposited);

        uint256 redeemed = vault.previewWithdraw(assets);

        bundle.push(_erc4626Withdraw(address(vault), assets, RECEIVER));

        vm.startPrank(USER);
        vault.approve(address(bundler), redeemed);
        bundler.multicall(bundle);
        vm.stopPrank();

        assertEq(loanToken.balanceOf(address(vault)), deposited - assets, "loan.balanceOf(vault)");
        assertEq(loanToken.balanceOf(address(bundler)), 0, "loan.balanceOf(bundler)");
        assertEq(loanToken.balanceOf(RECEIVER), assets, "loan.balanceOf(RECEIVER)");
        assertEq(vault.balanceOf(USER), minted - redeemed, "vault.balanceOf(USER)");
        assertEq(vault.balanceOf(RECEIVER), 0, "vault.balanceOf(RECEIVER)");
    }

    function testErc4626Redeem(uint256 deposited, uint256 shares) public {
        deposited = bound(deposited, MIN_AMOUNT, MAX_AMOUNT);

        uint256 minted = _depositVault(deposited);

        shares = bound(shares, 1, minted);

        uint256 withdrawn = vault.previewRedeem(shares);

        bundle.push(_erc4626Redeem(address(vault), shares, RECEIVER));

        vm.startPrank(USER);
        vault.approve(address(bundler), shares);
        bundler.multicall(bundle);
        vm.stopPrank();

        assertEq(loanToken.balanceOf(address(vault)), deposited - withdrawn, "loan.balanceOf(vault)");
        assertEq(loanToken.balanceOf(address(bundler)), 0, "loan.balanceOf(bundler)");
        assertEq(loanToken.balanceOf(RECEIVER), withdrawn, "loan.balanceOf(RECEIVER)");
        assertEq(vault.balanceOf(USER), minted - shares, "vault.balanceOf(USER)");
        assertEq(vault.balanceOf(RECEIVER), 0, "vault.balanceOf(RECEIVER)");
    }

    function _depositVault(uint256 assets) internal returns (uint256 shares) {
        loanToken.setBalance(USER, assets);

        vm.startPrank(USER);
        loanToken.approve(address(vault), assets);
        shares = vault.deposit(assets, USER);
        vm.stopPrank();
    }
}
