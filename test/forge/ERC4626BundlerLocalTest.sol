// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {ErrorsLib} from "contracts/libraries/ErrorsLib.sol";

import {ERC4626Mock} from "contracts/mocks/ERC4626Mock.sol";
import "contracts/mocks/bundlers/ERC4626BundlerMock.sol";

import "./helpers/LocalTest.sol";

contract ERC4626BundlerLocalTest is LocalTest {
    ERC4626Mock private vault;
    ERC4626BundlerMock internal bundler;

    function setUp() public override {
        super.setUp();

        vault = new ERC4626Mock(address(borrowableToken), "BorrowableToken Vault", "BV");
        bundler = new ERC4626BundlerMock();
    }

    function testErc4626MintZeroAdressTarget(uint256 shares) public {
        bundle.push(Call(abi.encodeCall(ERC4626Bundler.erc4626Mint, (address(0), shares, RECEIVER)), false));

        vm.expectRevert(bytes(ErrorsLib.ZERO_ADDRESS));
        bundler.multicall(block.timestamp, bundle);
    }

    function testErc4626MintZeroAdress(uint256 shares) public {
        bundle.push(Call(abi.encodeCall(ERC4626Bundler.erc4626Mint, (address(vault), shares, address(0))), false));

        vm.expectRevert(bytes(ErrorsLib.ZERO_ADDRESS));
        bundler.multicall(block.timestamp, bundle);
    }

    function testErc4626DepositZeroAdressTarget(uint256 assets) public {
        bundle.push(Call(abi.encodeCall(ERC4626Bundler.erc4626Deposit, (address(0), assets, RECEIVER)), false));

        vm.expectRevert(bytes(ErrorsLib.ZERO_ADDRESS));
        bundler.multicall(block.timestamp, bundle);
    }

    function testErc4626DepositZeroAdress(uint256 assets) public {
        bundle.push(Call(abi.encodeCall(ERC4626Bundler.erc4626Deposit, (address(vault), assets, address(0))), false));

        vm.expectRevert(bytes(ErrorsLib.ZERO_ADDRESS));
        bundler.multicall(block.timestamp, bundle);
    }

    function testErc4626WithdrawZeroAdressTarget(uint256 assets) public {
        bundle.push(Call(abi.encodeCall(ERC4626Bundler.erc4626Withdraw, (address(0), assets, RECEIVER)), false));

        vm.expectRevert(bytes(ErrorsLib.ZERO_ADDRESS));
        bundler.multicall(block.timestamp, bundle);
    }

    function testErc4626WithdrawZeroAdress(uint256 assets) public {
        bundle.push(Call(abi.encodeCall(ERC4626Bundler.erc4626Withdraw, (address(vault), assets, address(0))), false));

        vm.expectRevert(bytes(ErrorsLib.ZERO_ADDRESS));
        bundler.multicall(block.timestamp, bundle);
    }

    function testErc4626RedeemZeroAdressTarget(uint256 assets) public {
        bundle.push(Call(abi.encodeCall(ERC4626Bundler.erc4626Redeem, (address(0), assets, RECEIVER)), false));

        vm.expectRevert(bytes(ErrorsLib.ZERO_ADDRESS));
        bundler.multicall(block.timestamp, bundle);
    }

    function testErc4626RedeemZeroAdress(uint256 shares) public {
        bundle.push(Call(abi.encodeCall(ERC4626Bundler.erc4626Redeem, (address(vault), shares, address(0))), false));

        vm.expectRevert(bytes(ErrorsLib.ZERO_ADDRESS));
        bundler.multicall(block.timestamp, bundle);
    }

    function testErc4626MintZero() public {
        bundle.push(Call(abi.encodeCall(ERC4626Bundler.erc4626Mint, (address(vault), 0, RECEIVER)), false));

        vm.expectRevert(bytes(ErrorsLib.ZERO_AMOUNT));
        bundler.multicall(block.timestamp, bundle);
    }

    function testErc4626DepositZero() public {
        bundle.push(Call(abi.encodeCall(ERC4626Bundler.erc4626Deposit, (address(vault), 0, RECEIVER)), false));

        vm.expectRevert(bytes(ErrorsLib.ZERO_AMOUNT));
        bundler.multicall(block.timestamp, bundle);
    }

    function testErc4626WithdrawZero() public {
        bundle.push(Call(abi.encodeCall(ERC4626Bundler.erc4626Withdraw, (address(vault), 0, RECEIVER)), false));

        vm.expectRevert(bytes(ErrorsLib.ZERO_AMOUNT));
        bundler.multicall(block.timestamp, bundle);
    }

    function testErc4626RedeemZero() public {
        bundle.push(Call(abi.encodeCall(ERC4626Bundler.erc4626Redeem, (address(vault), 0, RECEIVER)), false));

        vm.expectRevert(bytes(ErrorsLib.ZERO_SHARES));
        bundler.multicall(block.timestamp, bundle);
    }

    function testErc4626Mint(uint256 shares) public {
        shares = bound(shares, MIN_AMOUNT, MAX_AMOUNT);

        uint256 assets = vault.previewMint(shares);

        bundle.push(Call(abi.encodeCall(Permit2Bundler.transferFrom2, (address(borrowableToken), assets)), false));
        bundle.push(Call(abi.encodeCall(ERC4626Bundler.erc4626Mint, (address(vault), shares, USER)), false));

        borrowableToken.setBalance(USER, assets);

        vm.startPrank(USER);
        borrowableToken.approve(address(bundler), assets);
        bundler.multicall(block.timestamp, bundle);
        vm.stopPrank();

        assertEq(borrowableToken.balanceOf(address(vault)), assets, "borrowable.balanceOf(vault)");
        assertEq(borrowableToken.balanceOf(address(bundler)), 0, "borrowable.balanceOf(bundler)");
        assertEq(vault.balanceOf(address(bundler)), 0, "vault.balanceOf(USER)");
        assertEq(vault.balanceOf(USER), shares, "vault.balanceOf(USER)");
    }

    function testErc4626Deposit(uint256 assets) public {
        assets = bound(assets, MIN_AMOUNT, MAX_AMOUNT);

        uint256 shares = vault.previewDeposit(assets);

        bundle.push(Call(abi.encodeCall(Permit2Bundler.transferFrom2, (address(borrowableToken), assets)), false));
        bundle.push(Call(abi.encodeCall(ERC4626Bundler.erc4626Mint, (address(vault), assets, USER)), false));

        borrowableToken.setBalance(USER, assets);

        vm.startPrank(USER);
        borrowableToken.approve(address(bundler), assets);
        bundler.multicall(block.timestamp, bundle);
        vm.stopPrank();

        assertEq(borrowableToken.balanceOf(address(vault)), assets, "borrowable.balanceOf(vault)");
        assertEq(borrowableToken.balanceOf(address(bundler)), 0, "borrowable.balanceOf(bundler)");
        assertEq(vault.balanceOf(address(bundler)), 0, "vault.balanceOf(USER)");
        assertEq(vault.balanceOf(USER), shares, "vault.balanceOf(USER)");
    }

    function testErc4626Redeem(uint256 deposited, uint256 assets) public {
        deposited = bound(deposited, MIN_AMOUNT, MAX_AMOUNT);

        uint256 minted = _depositVault(deposited);

        assets = bound(assets, MIN_AMOUNT, deposited);

        uint256 redeemed = vault.previewWithdraw(assets);

        bundle.push(Call(abi.encodeCall(ERC4626Bundler.erc4626Withdraw, (address(vault), assets, RECEIVER)), false));

        vm.startPrank(USER);
        vault.approve(address(bundler), redeemed);
        bundler.multicall(block.timestamp, bundle);
        vm.stopPrank();

        assertEq(borrowableToken.balanceOf(address(vault)), deposited - assets, "borrowable.balanceOf(vault)");
        assertEq(borrowableToken.balanceOf(address(bundler)), 0, "borrowable.balanceOf(bundler)");
        assertEq(borrowableToken.balanceOf(RECEIVER), assets, "borrowable.balanceOf(RECEIVER)");
        assertEq(vault.balanceOf(USER), minted - redeemed, "vault.balanceOf(USER)");
        assertEq(vault.balanceOf(RECEIVER), 0, "vault.balanceOf(RECEIVER)");
    }

    function testErc4626Withdraw(uint256 deposited, uint256 shares) public {
        deposited = bound(deposited, MIN_AMOUNT, MAX_AMOUNT);

        uint256 minted = _depositVault(deposited);

        shares = bound(shares, 1, minted);

        uint256 withdrawn = vault.previewRedeem(shares);

        bundle.push(Call(abi.encodeCall(ERC4626Bundler.erc4626Redeem, (address(vault), shares, RECEIVER)), false));

        vm.startPrank(USER);
        vault.approve(address(bundler), shares);
        bundler.multicall(block.timestamp, bundle);
        vm.stopPrank();

        assertEq(borrowableToken.balanceOf(address(vault)), deposited - withdrawn, "borrowable.balanceOf(vault)");
        assertEq(borrowableToken.balanceOf(address(bundler)), 0, "borrowable.balanceOf(bundler)");
        assertEq(borrowableToken.balanceOf(RECEIVER), withdrawn, "borrowable.balanceOf(RECEIVER)");
        assertEq(vault.balanceOf(USER), minted - shares, "vault.balanceOf(USER)");
        assertEq(vault.balanceOf(RECEIVER), 0, "vault.balanceOf(RECEIVER)");
    }

    function _depositVault(uint256 assets) internal returns (uint256 shares) {
        borrowableToken.setBalance(USER, assets);

        vm.startPrank(USER);
        borrowableToken.approve(address(vault), assets);
        shares = vault.deposit(assets, USER);
        vm.stopPrank();
    }
}
