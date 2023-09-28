// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {ErrorsLib} from "src/libraries/ErrorsLib.sol";

import "src/mocks/bundlers/WNativeBundlerMock.sol";

import "./helpers/EthereumTest.sol";

contract WNativeBundlerEthereumTest is EthereumTest {
    WNativeBundlerMock private bundler;

    function setUp() public override {
        super.setUp();

        bundler = new WNativeBundlerMock(WETH);

        vm.prank(USER);
        ERC20(WETH).approve(address(bundler), type(uint256).max);
    }

    function testWrapZeroAmount() public {
        bytes[] memory data = new bytes[](1);
        data[0] = abi.encodeCall(WNativeBundler.wrapNative, (0));

        vm.expectRevert(bytes(ErrorsLib.ZERO_AMOUNT));
        vm.prank(USER);
        bundler.multicall(data);
    }

    function testWrapNative(uint256 amount) public {
        amount = bound(amount, MIN_AMOUNT, MAX_AMOUNT);

        bundle.push(abi.encodeCall(WNativeBundler.wrapNative, (amount)));
        bundle.push(abi.encodeCall(BaseBundler.erc20Transfer, (WETH, RECEIVER, type(uint256).max)));

        vm.deal(USER, amount);
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
        bytes[] memory data = new bytes[](1);
        data[0] = abi.encodeCall(WNativeBundler.unwrapNative, (0));

        vm.expectRevert(bytes(ErrorsLib.ZERO_AMOUNT));
        vm.prank(USER);
        bundler.multicall(data);
    }

    function testUnwrapNative(uint256 amount) public {
        amount = bound(amount, MIN_AMOUNT, MAX_AMOUNT);

        bundle.push(abi.encodeCall(BaseBundler.erc20TransferFrom, (WETH, amount)));
        bundle.push(abi.encodeCall(WNativeBundler.unwrapNative, (amount)));
        bundle.push(abi.encodeCall(BaseBundler.nativeTransfer, (RECEIVER, type(uint256).max)));

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
