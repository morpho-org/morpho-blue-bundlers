// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {ErrorsLib} from "contracts/libraries/ErrorsLib.sol";

import "contracts/mocks/bundlers/Permit2BundlerMock.sol";

import "./helpers/LocalTest.sol";

contract Permit2BundlerLocalTest is LocalTest {
    Permit2BundlerMock internal bundler;

    bytes[] internal bundle;

    function setUp() public override {
        super.setUp();

        bundler = new Permit2BundlerMock();
    }

    function testTransferFrom2(uint256 amount) public {
        amount = bound(amount, MIN_AMOUNT, MAX_AMOUNT);

        bundle.push(abi.encodeCall(Permit2Bundler.transferFrom2, (address(borrowableToken), amount)));

        borrowableToken.setBalance(USER, amount);

        vm.startPrank(USER);
        borrowableToken.approve(address(bundler), amount);
        bundler.multicall(block.timestamp, bundle);
        vm.stopPrank();

        assertEq(borrowableToken.balanceOf(address(bundler)), amount, "borrowable.balanceOf(bundler)");
        assertEq(borrowableToken.balanceOf(USER), 0, "borrowable.balanceOf(USER)");
    }

    function testTransferFrom2Zero() public {
        bundle.push(abi.encodeCall(Permit2Bundler.transferFrom2, (address(borrowableToken), 0)));

        vm.expectRevert(bytes(ErrorsLib.ZERO_AMOUNT));
        bundler.multicall(block.timestamp, bundle);
    }
}
