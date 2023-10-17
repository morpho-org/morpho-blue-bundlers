// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {ErrorsLib} from "src/libraries/ErrorsLib.sol";

import "src/mocks/bundlers/WETHBundlerMock.sol";

import "./helpers/EthereumTest.sol";

contract WETHBundlerEthereumTest is EthereumTest {
    function setUp() public override {
        super.setUp();

        bundler = new WETHBundlerMock(WETH);

        vm.prank(USER);
        ERC20(WETH).approve(address(bundler), type(uint256).max);
    }

    function testWrapZeroAmount() public {
        bundle.push(abi.encodeCall(WETHBundler.wrapETH, (0)));

        vm.expectRevert(bytes(ErrorsLib.ZERO_AMOUNT));
        vm.prank(USER);
        bundler.multicall(bundle);
    }

    function testwrapETH(uint256 amount) public {
        amount = bound(amount, MIN_AMOUNT, MAX_AMOUNT);

        bundle.push(abi.encodeCall(WETHBundler.wrapETH, (amount)));
        bundle.push(_erc20Transfer(WETH, RECEIVER, type(uint256).max));

        deal(USER, amount);

        vm.prank(USER);
        bundler.multicall{value: amount}(bundle);

        assertEq(ERC20(WETH).balanceOf(address(bundler)), 0, "Bundler's wrapped token balance");
        assertEq(ERC20(WETH).balanceOf(USER), 0, "User's wrapped token balance");
        assertEq(ERC20(WETH).balanceOf(RECEIVER), amount, "Receiver's wrapped token balance");

        assertEq(address(bundler).balance, 0, "Bundler's native token balance");
        assertEq(USER.balance, 0, "User's native token balance");
        assertEq(RECEIVER.balance, 0, "Receiver's native token balance");
    }

    function testUnwrapZeroAmount() public {
        bundle.push(abi.encodeCall(WETHBundler.unwrapETH, (0)));

        vm.expectRevert(bytes(ErrorsLib.ZERO_AMOUNT));
        vm.prank(USER);
        bundler.multicall(bundle);
    }

    function testUnwrapETH(uint256 amount) public {
        amount = bound(amount, MIN_AMOUNT, MAX_AMOUNT);

        bundle.push(_erc20TransferFrom(WETH, amount));
        bundle.push(abi.encodeCall(WETHBundler.unwrapETH, (amount)));
        bundle.push(_nativeTransfer(RECEIVER, type(uint256).max));

        deal(WETH, USER, amount);

        vm.prank(USER);
        bundler.multicall(bundle);

        assertEq(ERC20(WETH).balanceOf(address(bundler)), 0, "Bundler's wrapped token balance");
        assertEq(ERC20(WETH).balanceOf(USER), 0, "User's wrapped token balance");
        assertEq(ERC20(WETH).balanceOf(RECEIVER), 0, "Receiver's wrapped token balance");

        assertEq(address(bundler).balance, 0, "Bundler's native token balance");
        assertEq(USER.balance, 0, "User's native token balance");
        assertEq(RECEIVER.balance, amount, "Receiver's native token balance");
    }
}
