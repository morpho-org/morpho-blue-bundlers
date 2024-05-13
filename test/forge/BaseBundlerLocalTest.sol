// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {ErrorsLib} from "src/libraries/ErrorsLib.sol";

import "src/mocks/bundlers/RootBundlerMock.sol";

import "./helpers/LocalTest.sol";

contract RootBundlerLocalTest is LocalTest {
    function setUp() public override {
        super.setUp();

        bundler = new RootBundlerMock();
    }

    function testMulticallEmpty() public {
        bundler.multicall(bundle);
    }

    function testNestedMulticall() public {
        bundle.push(abi.encodeCall(RootBundler.multicall, (callbackBundle)));

        vm.expectRevert(bytes(ErrorsLib.ALREADY_INITIATED));
        bundler.multicall(bundle);
    }
}
