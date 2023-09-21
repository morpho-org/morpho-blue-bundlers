// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {ErrorsLib} from "contracts/libraries/ErrorsLib.sol";

import "contracts/mocks/bundlers/BaseBundlerMock.sol";

import "./helpers/LocalTest.sol";

contract BaseBundlerLocalTest is LocalTest {
    BaseBundlerMock internal bundler;

    bytes[] internal bundle;

    function setUp() public override {
        super.setUp();

        bundler = new BaseBundlerMock();
    }

    function testTransfer(uint256 amount) public {
        amount = bound(amount, MIN_AMOUNT, MAX_AMOUNT);

        bundle.push(abi.encodeCall(BaseBundler.transfer, (address(borrowableToken), RECEIVER, amount)));

        borrowableToken.setBalance(address(bundler), amount);

        bundler.multicall(block.timestamp, bundle);

        assertEq(borrowableToken.balanceOf(address(bundler)), 0, "borrowable.balanceOf(bundler)");
        assertEq(borrowableToken.balanceOf(RECEIVER), amount, "borrowable.balanceOf(RECEIVER)");
    }

    function testTranferZeroAddress(uint256 amount) public {
        amount = bound(amount, MIN_AMOUNT, MAX_AMOUNT);

        bundle.push(abi.encodeCall(BaseBundler.transfer, (address(borrowableToken), address(0), amount)));

        vm.expectRevert(bytes(ErrorsLib.ZERO_ADDRESS));
        bundler.multicall(block.timestamp, bundle);
    }

    function testTranferBundlerAddress(uint256 amount) public {
        amount = bound(amount, MIN_AMOUNT, MAX_AMOUNT);

        bundle.push(abi.encodeCall(BaseBundler.transfer, (address(borrowableToken), address(bundler), amount)));

        vm.expectRevert(bytes(ErrorsLib.BUNDLER_ADDRESS));
        bundler.multicall(block.timestamp, bundle);
    }

    function testTranferZeroAmount() public {
        bundle.push(abi.encodeCall(BaseBundler.transfer, (address(borrowableToken), RECEIVER, 0)));

        vm.expectRevert(bytes(ErrorsLib.ZERO_AMOUNT));
        bundler.multicall(block.timestamp, bundle);
    }

    function testTransferFrom(uint256 amount) public {
        amount = bound(amount, MIN_AMOUNT, MAX_AMOUNT);

        bundle.push(abi.encodeCall(BaseBundler.transferFrom, (address(borrowableToken), amount)));

        borrowableToken.setBalance(USER, amount);

        vm.startPrank(USER);
        borrowableToken.approve(address(bundler), type(uint256).max);
        bundler.multicall(block.timestamp, bundle);
        vm.stopPrank();

        assertEq(borrowableToken.balanceOf(address(bundler)), amount, "borrowable.balanceOf(bundler)");
        assertEq(borrowableToken.balanceOf(USER), 0, "borrowable.balanceOf(USER)");
    }

    function testTranferFromZeroAddress(uint256 amount) public {
        amount = bound(amount, MIN_AMOUNT, MAX_AMOUNT);

        bundle.push(abi.encodeCall(BaseBundler.transferFrom, (address(0), amount)));

        vm.prank(USER);
        vm.expectRevert(bytes(ErrorsLib.ZERO_ADDRESS));
        bundler.multicall(block.timestamp, bundle);
    }

    function testTranferFromZeroAmount() public {
        bundle.push(abi.encodeCall(BaseBundler.transferFrom, (address(borrowableToken), 0)));

        vm.prank(USER);
        vm.expectRevert(bytes(ErrorsLib.ZERO_AMOUNT));
        bundler.multicall(block.timestamp, bundle);
    }
}
