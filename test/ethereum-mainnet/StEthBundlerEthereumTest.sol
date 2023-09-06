// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {SigUtils} from "test/helpers/SigUtils.sol";
import {ErrorsLib as BulkerErrorsLib} from "contracts/libraries/ErrorsLib.sol";

import {ILido} from "contracts/interfaces/ILido.sol";

import "../helpers/ForkTest.sol";

import "../mocks/StEthBundlerMock.sol";

contract StEthBundlerEthereumTest is ForkTest {
    StEthBundlerMock private bundler;

    function _network() internal pure override returns (string memory) {
        return "ethereum-mainnet";
    }

    function setUp() public override {
        super.setUp();

        bundler = new StEthBundlerMock();

        vm.prank(USER);
        ERC20(ST_ETH).approve(address(bundler), type(uint256).max);
    }

    function testWrapZeroAddress(uint256 amount) public {
        vm.assume(amount != 0);

        bytes[] memory data = new bytes[](1);
        data[0] = abi.encodeCall(StEthBundler.wrapStEth, (amount, address(0)));

        vm.expectRevert(bytes(BulkerErrorsLib.ZERO_ADDRESS));
        vm.prank(USER);
        bundler.multicall(block.timestamp, data);
    }

    function testWrapZeroAmount(address receiver) public {
        vm.assume(receiver != address(bundler) && receiver != address(0));

        bytes[] memory data = new bytes[](1);
        data[0] = abi.encodeCall(StEthBundler.wrapStEth, (0, receiver));

        vm.expectRevert(bytes(BulkerErrorsLib.ZERO_AMOUNT));
        vm.prank(USER);
        bundler.multicall(block.timestamp, data);
    }

    function testwrapStEth(uint256 amount) public {
        amount = bound(amount, MIN_AMOUNT, MAX_AMOUNT);

        bytes[] memory data = new bytes[](2);
        data[0] = abi.encodeCall(ERC20Bundler.transferFrom2, (ST_ETH, amount));
        data[1] = abi.encodeCall(StEthBundler.wrapStEth, (amount, RECEIVER));

        vm.deal(USER, amount);
        vm.startPrank(USER);
        ILido(ST_ETH).submit{value: amount}(address(0));
        bundler.multicall(block.timestamp, data);
        vm.stopPrank();

        // assertEq(ERC20(WETH).balanceOf(address(bundler)), 0, "Bundler's wrapped token balance");
        // assertEq(ERC20(WETH).balanceOf(USER), 0, "User's wrapped token balance");
        // assertEq(ERC20(WETH).balanceOf(RECEIVER), amount, "Receiver's wrapped token balance");

        // assertEq(address(bundler).balance, 0, "Bundler's native token balance");
        // assertEq(USER.balance, 0, "User's native token balance");
        // assertEq(RECEIVER.balance, 0, "Receiver's native token balance");
    }

    function testUnwrapZeroAddress(uint256 amount) public {
        vm.assume(amount != 0);

        bytes[] memory data = new bytes[](1);
        data[0] = abi.encodeCall(StEthBundler.unwrapStEth, (amount, address(0)));

        vm.expectRevert(bytes(BulkerErrorsLib.ZERO_ADDRESS));
        vm.prank(USER);
        bundler.multicall(block.timestamp, data);
    }

    function testUnwrapBundlerAddress(uint256 amount) public {
        vm.assume(amount != 0);

        bytes[] memory data = new bytes[](1);
        data[0] = abi.encodeCall(StEthBundler.unwrapStEth, (amount, address(bundler)));

        vm.expectRevert(bytes(BulkerErrorsLib.BUNDLER_ADDRESS));
        vm.prank(USER);
        bundler.multicall(block.timestamp, data);
    }

    function testUnwrapZeroAmount(address receiver) public {
        vm.assume(receiver != address(bundler) && receiver != address(0));

        bytes[] memory data = new bytes[](1);
        data[0] = abi.encodeCall(StEthBundler.unwrapStEth, (0, receiver));

        vm.expectRevert(bytes(BulkerErrorsLib.ZERO_AMOUNT));
        vm.prank(USER);
        bundler.multicall(block.timestamp, data);
    }

    // function testUnwrapStEth(uint256 amount) public {
    //     amount = bound(amount, MIN_AMOUNT, MAX_AMOUNT);

    //     bytes[] memory data = new bytes[](2);
    //     data[0] = abi.encodeCall(ERC20Bundler.transferFrom2, (address(WETH), amount));
    //     data[1] = abi.encodeCall(StEthBundler.unwrapStEth, (amount, RECEIVER));

    //     deal(WETH, USER, amount);
    //     vm.prank(USER);
    //     bundler.multicall(block.timestamp, data);

    //     assertEq(ERC20(WETH).balanceOf(address(bundler)), 0, "Bundler's wrapped token balance");
    //     assertEq(ERC20(WETH).balanceOf(USER), 0, "User's wrapped token balance");
    //     assertEq(ERC20(WETH).balanceOf(RECEIVER), 0, "Receiver's wrapped token balance");

    //     assertEq(address(bundler).balance, 0, "Bundler's native token balance");
    //     assertEq(USER.balance, 0, "User's native token balance");
    //     assertEq(RECEIVER.balance, amount, "Receiver's native token balance");
    // }
}
