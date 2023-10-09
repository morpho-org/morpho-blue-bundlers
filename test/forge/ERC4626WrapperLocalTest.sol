// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {ERC4626Mock} from "src/mocks/ERC4626Mock.sol";

import "./helpers/LocalTest.sol";

contract ERC4626WrapperLocalTest is LocalTest {
    ERC4626Mock internal wrapper;

    function setUp() public override {
        super.setUp();

        wrapper = new ERC4626Mock(address(loanToken), "Wrapper", "W");

        loanToken.setBalance(SUPPLIER, type(uint256).max);

        vm.prank(SUPPLIER);
        loanToken.approve(address(wrapper), type(uint256).max);
    }

    function testMint() public {
        vm.prank(SUPPLIER);
        wrapper.mint(1 ether, SUPPLIER);
    }

    function testBurn() public {
        vm.startPrank(SUPPLIER);
        wrapper.mint(1 ether, SUPPLIER);
        wrapper.redeem(0.5 ether, SUPPLIER, SUPPLIER);
        vm.stopPrank();
    }
}
