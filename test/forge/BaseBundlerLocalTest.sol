// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {ErrorsLib} from "contracts/libraries/ErrorsLib.sol";

import "contracts/mocks/bundlers/BaseBundlerMock.sol";

import "./helpers/LocalTest.sol";

contract BaseBundlerLocalTest is LocalTest {
    BaseBundlerMock internal bundler;

    function setUp() public override {
        super.setUp();

        bundler = new BaseBundlerMock();
    }

    function testTransfer(uint256 amount) public {
        amount = bound(amount, MIN_AMOUNT, MAX_AMOUNT);

        bundle.push(Call(abi.encodeCall(BaseBundler.transfer, (address(borrowableToken), RECEIVER, amount)), false));

        borrowableToken.setBalance(address(bundler), amount);

        bundler.multicall(block.timestamp, bundle);

        assertEq(borrowableToken.balanceOf(address(bundler)), 0, "borrowable.balanceOf(bundler)");
        assertEq(borrowableToken.balanceOf(RECEIVER), amount, "borrowable.balanceOf(RECEIVER)");
    }

    function testTranferZeroAddress(uint256 amount) public {
        amount = bound(amount, MIN_AMOUNT, MAX_AMOUNT);

        bundle.push(Call(abi.encodeCall(BaseBundler.transfer, (address(borrowableToken), address(0), amount)), false));

        vm.expectRevert(bytes(ErrorsLib.ZERO_ADDRESS));
        bundler.multicall(block.timestamp, bundle);
    }

    function testTranferBundlerAddress(uint256 amount) public {
        amount = bound(amount, MIN_AMOUNT, MAX_AMOUNT);

        bundle.push(
            Call(abi.encodeCall(BaseBundler.transfer, (address(borrowableToken), address(bundler), amount)), false)
        );

        vm.expectRevert(bytes(ErrorsLib.BUNDLER_ADDRESS));
        bundler.multicall(block.timestamp, bundle);
    }

    function testTranferZero() public {
        bundle.push(Call(abi.encodeCall(BaseBundler.transfer, (address(borrowableToken), RECEIVER, 0)), false));

        vm.expectRevert(bytes(ErrorsLib.ZERO_AMOUNT));
        bundler.multicall(block.timestamp, bundle);
    }
}
