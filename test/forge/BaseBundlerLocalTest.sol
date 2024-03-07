// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {ErrorsLib} from "src/libraries/ErrorsLib.sol";

import "src/mocks/bundlers/BaseBundlerMock.sol";

import "./helpers/LocalTest.sol";

contract BaseBundlerLocalTest is LocalTest {
    function setUp() public override {
        super.setUp();

        bundler = new BaseBundlerMock();
    }

    function testMulticallEmpty() public {
        bundler.multicall(bundle);
    }

    function testNestedMulticall() public {
        bundle.push(abi.encodeCall(BaseBundler.multicall, (callbackBundle)));

        vm.expectRevert(bytes(ErrorsLib.ALREADY_INITIATED));
        bundler.multicall(bundle);
    }
}

contract BaseBundlerLocalEnshrinedTest is BaseBundler, LocalTest {
    function checkInitiator(address expectedInitiator) public payable protected {
        require(initiator() == expectedInitiator, "unexpected initiator");
    }

    function revertWith(string memory data) public payable protected {
        revert(data);
    }

    function testMulticallShouldSetTheRightInitiator(address caller) public {
        bundle.push(abi.encodeCall(this.checkInitiator, (caller)));

        vm.prank(caller);
        this.multicall(bundle);
    }

    function testMulticallShouldPassRevertData(string memory data) public {
        bundle.push(abi.encodeCall(this.revertWith, (data)));

        vm.expectRevert(bytes(data));
        this.multicall(bundle);
    }
}
