// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {ERC20WrapperMock} from "src/mocks/ERC20WrapperMock.sol";

import "./helpers/LocalTest.sol";

contract ERC20WrapperLocalTest is LocalTest {
    ERC20WrapperMock internal wrapper;

    function setUp() public override {
        super.setUp();

        wrapper = new ERC20WrapperMock(address(loanToken));

        loanToken.setBalance(SUPPLIER, type(uint256).max);

        vm.prank(SUPPLIER);
        loanToken.approve(address(wrapper), type(uint256).max);
    }

    function testMint() public {
        vm.prank(SUPPLIER);
        wrapper.depositFor(SUPPLIER, 1 ether);
    }

    function testBurn() public {
        vm.startPrank(SUPPLIER);
        wrapper.depositFor(SUPPLIER, 1 ether);
        wrapper.withdrawTo(SUPPLIER, 0.5 ether);
        vm.stopPrank();
    }
}
