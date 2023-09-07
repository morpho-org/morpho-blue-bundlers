// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {SigUtils} from "test/helpers/SigUtils.sol";
import {ErrorsLib as BulkerErrorsLib} from "contracts/libraries/ErrorsLib.sol";

import {ILido} from "contracts/ethereum-mainnet/interfaces/ILido.sol";
import {IWStEth} from "contracts/ethereum-mainnet/interfaces/IWStEth.sol";

import "../helpers/ForkTest.sol";

import "../mocks/StEthBundlerMock.sol";

contract StEthBundlerEthereumTest is ForkTest {
    address public constant WST_ETH = 0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0;
    StEthBundlerMock private bundler;

    function _network() internal pure override returns (string memory) {
        return "ethereum-mainnet";
    }

    function setUp() public override {
        super.setUp();

        bundler = new StEthBundlerMock();

        vm.startPrank(USER);
        ERC20(ST_ETH).approve(address(bundler), type(uint256).max);
        ERC20(WST_ETH).approve(address(bundler), type(uint256).max);
        vm.stopPrank();
    }

    function testTransferStEthSharesFromZeroAmount() public {
        bytes[] memory data = new bytes[](1);
        data[0] = abi.encodeCall(StEthBundler.transferSharesFrom, (0));

        vm.prank(USER);
        vm.expectRevert(bytes(BulkerErrorsLib.ZERO_AMOUNT));
        bundler.multicall(block.timestamp, data);
    }

    function testTransferStEthSharesFrom(uint256 amount) public {
        amount = bound(amount, MIN_AMOUNT, MAX_AMOUNT);

        vm.deal(USER, amount);
        vm.prank(USER);
        uint256 stEthAmount = ILido(ST_ETH).submit{value: amount}(address(0));
        vm.assume(stEthAmount != 0);

        uint256 stEthUserBalanceBeforeTransfer = ERC20(ST_ETH).balanceOf(USER);

        bytes[] memory data = new bytes[](1);
        data[0] = abi.encodeCall(StEthBundler.transferSharesFrom, (stEthAmount));

        vm.prank(USER);
        bundler.multicall(block.timestamp, data);

        assertEq(ERC20(ST_ETH).balanceOf(USER), 0, "User's StEth Balance");
        assertEq(ERC20(ST_ETH).balanceOf(address(bundler)), stEthUserBalanceBeforeTransfer, "Receiver's StEth Balance");
    }

    function testWrapZeroAddress(uint256 amount) public {
        vm.assume(amount != 0);

        bytes[] memory data = new bytes[](1);
        data[0] = abi.encodeCall(StEthBundler.wrapStEth, (amount, address(0)));

        vm.expectRevert(bytes(BulkerErrorsLib.ZERO_ADDRESS));
        vm.prank(USER);
        bundler.multicall(block.timestamp, data);
    }

    function testWrapZeroAmount(address receiver) public {
        vm.assume(receiver != address(bundler) && receiver != address(0));

        bytes[] memory data = new bytes[](1);
        data[0] = abi.encodeCall(StEthBundler.wrapStEth, (0, receiver));

        vm.expectRevert(bytes(BulkerErrorsLib.ZERO_AMOUNT));
        vm.prank(USER);
        bundler.multicall(block.timestamp, data);
    }

    function testWrapStEth(uint256 amount) public {
        amount = bound(amount, MIN_AMOUNT, MAX_AMOUNT);

        vm.deal(USER, amount);
        vm.prank(USER);
        uint256 stEthAmount = ILido(ST_ETH).submit{value: amount}(address(0));
        vm.assume(stEthAmount != 0);

        bytes[] memory data = new bytes[](2);
        data[0] = abi.encodeCall(StEthBundler.transferSharesFrom, (stEthAmount));
        data[1] = abi.encodeCall(StEthBundler.wrapStEth, (amount, RECEIVER));

        uint256 wstEthExpectedAmount = ILido(ST_ETH).getSharesByPooledEth(amount);

        vm.prank(USER);
        bundler.multicall(block.timestamp, data);

        assertEq(ERC20(WST_ETH).balanceOf(address(bundler)), 0, "Bundler's wrapped stEth balance");
        assertEq(ERC20(WST_ETH).balanceOf(USER), 0, "User's wrapped stEth balance");
        assertEq(ERC20(WST_ETH).balanceOf(RECEIVER), wstEthExpectedAmount, "Receiver's wrapped stEth balance");

        assertEq(ERC20(ST_ETH).balanceOf(address(bundler)), 0, "Bundler's stEth balance");
        assertEq(ERC20(ST_ETH).balanceOf(USER), 0, "User's stEth balance");
        assertEq(ERC20(ST_ETH).balanceOf(RECEIVER), 0, "Receiver's stEth balance");
    }

    function testUnwrapZeroAddress(uint256 amount) public {
        vm.assume(amount != 0);

        bytes[] memory data = new bytes[](1);
        data[0] = abi.encodeCall(StEthBundler.unwrapStEth, (amount, address(0)));

        vm.expectRevert(bytes(BulkerErrorsLib.ZERO_ADDRESS));
        vm.prank(USER);
        bundler.multicall(block.timestamp, data);
    }

    function testUnwrapBundlerAddress(uint256 amount) public {
        vm.assume(amount != 0);

        bytes[] memory data = new bytes[](1);
        data[0] = abi.encodeCall(StEthBundler.unwrapStEth, (amount, address(bundler)));

        vm.expectRevert(bytes(BulkerErrorsLib.BUNDLER_ADDRESS));
        vm.prank(USER);
        bundler.multicall(block.timestamp, data);
    }

    function testUnwrapZeroAmount(address receiver) public {
        vm.assume(receiver != address(bundler) && receiver != address(0));

        bytes[] memory data = new bytes[](1);
        data[0] = abi.encodeCall(StEthBundler.unwrapStEth, (0, receiver));

        vm.expectRevert(bytes(BulkerErrorsLib.ZERO_AMOUNT));
        vm.prank(USER);
        bundler.multicall(block.timestamp, data);
    }

    function testUnwrapWstEth(uint256 amount) public {
        amount = bound(amount, MIN_AMOUNT, MAX_AMOUNT);

        bytes[] memory data = new bytes[](2);
        data[0] = abi.encodeCall(ERC20Bundler.transferFrom2, (WST_ETH, amount));
        data[1] = abi.encodeCall(StEthBundler.unwrapStEth, (amount, RECEIVER));

        deal(WST_ETH, USER, amount);
        console2.log(amount, "amount", ERC20(WST_ETH).balanceOf(USER), "User's WST_ETH balance");
        vm.prank(USER);
        bundler.multicall(block.timestamp, data);

        uint256 expectedUnwrappedAmount = IWStEth(WST_ETH).getStETHByWstETH(amount);

        assertEq(ERC20(WST_ETH).balanceOf(address(bundler)), 0, "Bundler's wrapped stEth balance");
        assertEq(ERC20(WST_ETH).balanceOf(USER), 0, "User's wrapped stEth balance");
        assertEq(ERC20(WST_ETH).balanceOf(RECEIVER), 0, "Receiver's wrapped stEth balance");

        assertEq(ERC20(ST_ETH).balanceOf(address(bundler)), 0, "Bundler's stEth balance");
        assertEq(ERC20(ST_ETH).balanceOf(USER), 0, "User's stEth balance");
        assertApproxEqAbs(ERC20(ST_ETH).balanceOf(RECEIVER), expectedUnwrappedAmount, 2, "Receiver's stEth balance");
    }
}
