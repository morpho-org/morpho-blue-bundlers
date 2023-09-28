// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {ErrorsLib} from "src/libraries/ErrorsLib.sol";

import "src/mocks/bundlers/BaseBundlerMock.sol";

import "./helpers/LocalTest.sol";

contract BaseBundlerLocalTest is LocalTest {
    BaseBundlerMock internal bundler;

    function setUp() public override {
        super.setUp();

        bundler = new BaseBundlerMock();
    }

    function testTransfer(uint256 amount) public {
        amount = bound(amount, MIN_AMOUNT, MAX_AMOUNT);

        bundle.push(abi.encodeCall(BaseBundler.transfer, (address(loanToken), RECEIVER, amount)));

        loanToken.setBalance(address(bundler), amount);

        bundler.multicall(block.timestamp, bundle);

        assertEq(loanToken.balanceOf(address(bundler)), 0, "loan.balanceOf(bundler)");
        assertEq(loanToken.balanceOf(RECEIVER), amount, "loan.balanceOf(RECEIVER)");
    }

    function testTranferZeroAddress(uint256 amount) public {
        amount = bound(amount, MIN_AMOUNT, MAX_AMOUNT);

        bundle.push(abi.encodeCall(BaseBundler.transfer, (address(loanToken), address(0), amount)));

        vm.expectRevert(bytes(ErrorsLib.ZERO_ADDRESS));
        bundler.multicall(block.timestamp, bundle);
    }

    function testTranferBundlerAddress(uint256 amount) public {
        amount = bound(amount, MIN_AMOUNT, MAX_AMOUNT);

        bundle.push(abi.encodeCall(BaseBundler.transfer, (address(loanToken), address(bundler), amount)));

        vm.expectRevert(bytes(ErrorsLib.BUNDLER_ADDRESS));
        bundler.multicall(block.timestamp, bundle);
    }

    function testTranferZeroAmount() public {
        bundle.push(abi.encodeCall(BaseBundler.transfer, (address(loanToken), RECEIVER, 0)));

        vm.expectRevert(bytes(ErrorsLib.ZERO_AMOUNT));
        bundler.multicall(block.timestamp, bundle);
    }

    function testTransferNativeZeroAddress(uint256 amount) public {
        amount = bound(amount, MIN_AMOUNT, MAX_AMOUNT);

        bundle.push(abi.encodeCall(BaseBundler.transferNative, (address(0), amount)));

        vm.expectRevert(bytes(ErrorsLib.ZERO_ADDRESS));
        bundler.multicall(block.timestamp, bundle);
    }

    function testTransferNativeBundlerAddress(uint256 amount) public {
        amount = bound(amount, MIN_AMOUNT, MAX_AMOUNT);

        bundle.push(abi.encodeCall(BaseBundler.transferNative, (address(bundler), amount)));

        vm.expectRevert(bytes(ErrorsLib.BUNDLER_ADDRESS));
        bundler.multicall(block.timestamp, bundle);
    }

    function testTransferNativeZeroAmount() public {
        bundle.push(abi.encodeCall(BaseBundler.transferNative, (RECEIVER, 0)));

        vm.expectRevert(bytes(ErrorsLib.ZERO_AMOUNT));
        bundler.multicall(block.timestamp, bundle);
    }

    function testTransferFrom(uint256 amount) public {
        amount = bound(amount, MIN_AMOUNT, MAX_AMOUNT);

        bundle.push(abi.encodeCall(BaseBundler.transferFrom, (address(loanToken), amount)));

        loanToken.setBalance(USER, amount);

        vm.startPrank(USER);
        loanToken.approve(address(bundler), type(uint256).max);
        bundler.multicall(block.timestamp, bundle);
        vm.stopPrank();

        assertEq(loanToken.balanceOf(address(bundler)), amount, "loan.balanceOf(bundler)");
        assertEq(loanToken.balanceOf(USER), 0, "loan.balanceOf(USER)");
    }

    function testTranferFromZeroAddress(uint256 amount) public {
        amount = bound(amount, MIN_AMOUNT, MAX_AMOUNT);

        bundle.push(abi.encodeCall(BaseBundler.transferFrom, (address(0), amount)));

        vm.prank(USER);
        vm.expectRevert();
        bundler.multicall(block.timestamp, bundle);
    }

    function testTranferFromZeroAmount() public {
        bundle.push(abi.encodeCall(BaseBundler.transferFrom, (address(loanToken), 0)));

        vm.prank(USER);
        vm.expectRevert(bytes(ErrorsLib.ZERO_AMOUNT));
        bundler.multicall(block.timestamp, bundle);
    }
}
