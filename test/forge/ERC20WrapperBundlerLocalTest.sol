// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {ErrorsLib} from "../../src/libraries/ErrorsLib.sol";

import {ERC20WrapperBundlerMock} from "../../src/mocks/bundlers/ERC20WrapperBundlerMock.sol";
import {ERC20WrapperMock} from "../../src/mocks/ERC20WrapperMock.sol";

import "./helpers/LocalTest.sol";

contract ERC20WrapperBundlerBundlerLocalTest is LocalTest {
    ERC20WrapperMock internal loanWrapper;

    function setUp() public override {
        super.setUp();

        bundler = new ERC20WrapperBundlerMock();

        loanWrapper = new ERC20WrapperMock(loanToken, "Wrapped Loan Token", "WLT");
    }

    function testErc20WrapperDepositFor(uint256 amount) public {
        amount = bound(amount, MIN_AMOUNT, MAX_AMOUNT);

        bundle.push(_erc20WrapperDepositFor(address(loanWrapper), amount));

        loanToken.setBalance(address(bundler), amount);

        vm.prank(RECEIVER);
        bundler.multicall(bundle);

        assertEq(loanToken.balanceOf(address(bundler)), 0, "loan.balanceOf(bundler)");
        assertEq(loanWrapper.balanceOf(RECEIVER), amount, "loanWrapper.balanceOf(RECEIVER)");
    }

    function testErc20WrapperDepositForZeroAmount() public {
        bundle.push(_erc20WrapperDepositFor(address(loanWrapper), 0));

        vm.expectRevert(bytes(ErrorsLib.ZERO_AMOUNT));
        bundler.multicall(bundle);
    }

    function testErc20WrapperWithdrawTo(uint256 amount) public {
        amount = bound(amount, MIN_AMOUNT, MAX_AMOUNT);

        loanWrapper.setBalance(address(bundler), amount);
        loanToken.setBalance(address(loanWrapper), amount);

        bundle.push(_erc20WrapperWithdrawTo(address(loanWrapper), RECEIVER, amount));

        bundler.multicall(bundle);

        assertEq(loanWrapper.balanceOf(address(bundler)), 0, "loanWrapper.balanceOf(bundler)");
        assertEq(loanToken.balanceOf(RECEIVER), amount, "loan.balanceOf(RECEIVER)");
    }

    function testErc20WrapperWithdrawToAccountZeroAddress(uint256 amount) public {
        amount = bound(amount, MIN_AMOUNT, MAX_AMOUNT);

        bundle.push(_erc20WrapperWithdrawTo(address(loanWrapper), address(0), amount));

        vm.expectRevert(bytes(ErrorsLib.ZERO_ADDRESS));
        bundler.multicall(bundle);
    }

    function testErc20WrapperWithdrawToZeroAmount() public {
        bundle.push(_erc20WrapperWithdrawTo(address(loanWrapper), RECEIVER, 0));

        vm.expectRevert(bytes(ErrorsLib.ZERO_AMOUNT));
        bundler.multicall(bundle);
    }
}
