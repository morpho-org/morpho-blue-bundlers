// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {ERC20WrapperMock} from "src/mocks/ERC20WrapperMock.sol";

import "./helpers/LocalTest.sol";

contract ERC20WrapperMintLocalTest is LocalTest {
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
}
