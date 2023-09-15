// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {ECDSA} from "@openzeppelin/utils/cryptography/ECDSA.sol";
import {SigUtils} from "test/forge/helpers/SigUtils.sol";
import {ErrorsLib} from "contracts/libraries/ErrorsLib.sol";

import {IAllowanceTransfer} from "@permit2/interfaces/IAllowanceTransfer.sol";
import {IStEth} from "contracts/ethereum-mainnet/interfaces/IStEth.sol";
import {IWStEth} from "contracts/ethereum-mainnet/interfaces/IWStEth.sol";

import "contracts/mocks/bundlers/ethereum-mainnet/StEthBundlerMock.sol";

import "./helpers/EthereumTest.sol";

contract StEthBundlerEthereumTest is EthereumTest {
    StEthBundlerMock private bundler;

    function setUp() public override {
        super.setUp();

        bundler = new StEthBundlerMock();
    }

    function testWrapZeroAddress(uint256 amount) public {
        vm.assume(amount != 0);

        bytes[] memory data = new bytes[](1);
        data[0] = abi.encodeCall(StEthBundler.wrapStEth, (amount, address(0)));

        vm.expectRevert(bytes(ErrorsLib.ZERO_ADDRESS));
        vm.prank(USER);
        bundler.multicall(block.timestamp, data);
    }

    function testWrapZeroAmount() public {
        bytes[] memory data = new bytes[](1);
        data[0] = abi.encodeCall(StEthBundler.wrapStEth, (0, RECEIVER));

        vm.expectRevert(bytes(ErrorsLib.ZERO_AMOUNT));
        vm.prank(USER);
        bundler.multicall(block.timestamp, data);
    }

    function testWrapStEth(uint256 amount, uint256 privateKey) public {
        amount = bound(amount, MIN_AMOUNT, MAX_AMOUNT);
        privateKey = bound(privateKey, 1, type(uint160).max);

        address user = _getAddressFromPrivateKey(privateKey);
        _approvePermit2(user);

        _mintStEth(amount, user);
        amount = ERC20(ST_ETH).balanceOf(user);

        bytes[] memory data = new bytes[](3);
        data[0] = _getPermit2Data(ST_ETH, privateKey, user);
        data[1] = abi.encodeCall(Permit2Bundler.transferFrom2, (ST_ETH, amount));
        data[2] = abi.encodeCall(StEthBundler.wrapStEth, (amount, RECEIVER));

        uint256 wstEthExpectedAmount = IStEth(ST_ETH).getSharesByPooledEth(ERC20(ST_ETH).balanceOf(user));

        vm.prank(user);
        bundler.multicall(block.timestamp, data);

        assertEq(ERC20(WST_ETH).balanceOf(address(bundler)), 0, "wstEth.balanceOf(bundler)");
        assertEq(ERC20(WST_ETH).balanceOf(user), 0, "wstEth.balanceOf(user)");
        assertApproxEqAbs(ERC20(WST_ETH).balanceOf(RECEIVER), wstEthExpectedAmount, 1, "wstEth.balanceOf(RECEIVER)");

        assertApproxEqAbs(ERC20(ST_ETH).balanceOf(address(bundler)), 0, 1, "wstEth.balanceOf(bundler)");
        assertApproxEqAbs(ERC20(ST_ETH).balanceOf(user), 0, 1, "wstEth.balanceOf(user)");
        assertEq(ERC20(ST_ETH).balanceOf(RECEIVER), 0, "wstEth.balanceOf(RECEIVER)");
    }

    function testUnwrapZeroAddress(uint256 amount) public {
        vm.assume(amount != 0);

        bytes[] memory data = new bytes[](1);
        data[0] = abi.encodeCall(StEthBundler.unwrapStEth, (amount, address(0)));

        vm.expectRevert(bytes(ErrorsLib.ZERO_ADDRESS));
        vm.prank(USER);
        bundler.multicall(block.timestamp, data);
    }

    function testUnwrapBundlerAddress(uint256 amount) public {
        vm.assume(amount != 0);

        bytes[] memory data = new bytes[](1);
        data[0] = abi.encodeCall(StEthBundler.unwrapStEth, (amount, address(bundler)));

        vm.expectRevert(bytes(ErrorsLib.BUNDLER_ADDRESS));
        vm.prank(USER);
        bundler.multicall(block.timestamp, data);
    }

    function testUnwrapZeroAmount() public {
        bytes[] memory data = new bytes[](1);
        data[0] = abi.encodeCall(StEthBundler.unwrapStEth, (0, RECEIVER));

        vm.expectRevert(bytes(ErrorsLib.ZERO_AMOUNT));
        vm.prank(USER);
        bundler.multicall(block.timestamp, data);
    }

    function testUnwrapWstEth(uint256 amount, uint256 privateKey) public {
        amount = bound(amount, MIN_AMOUNT, MAX_AMOUNT);
        privateKey = bound(privateKey, 1, type(uint160).max);

        address user = _getAddressFromPrivateKey(privateKey);
        _approvePermit2(user);

        bytes[] memory data = new bytes[](3);
        data[0] = _getPermit2Data(WST_ETH, privateKey, user);
        data[1] = abi.encodeCall(Permit2Bundler.transferFrom2, (WST_ETH, amount));
        data[2] = abi.encodeCall(StEthBundler.unwrapStEth, (amount, RECEIVER));

        deal(WST_ETH, user, amount);
        vm.prank(user);
        bundler.multicall(block.timestamp, data);

        uint256 expectedUnwrappedAmount = IWStEth(WST_ETH).getStETHByWstETH(amount);

        assertEq(ERC20(WST_ETH).balanceOf(address(bundler)), 0, "wstEth.balanceOf(bundler)");
        assertEq(ERC20(WST_ETH).balanceOf(user), 0, "wstEth.balanceOf(user)");
        assertEq(ERC20(WST_ETH).balanceOf(RECEIVER), 0, "wstEth.balanceOf(RECEIVER)");

        assertEq(ERC20(ST_ETH).balanceOf(address(bundler)), 0, "stEth.balanceOf(bundler)");
        assertEq(ERC20(ST_ETH).balanceOf(user), 0, "stEth.balanceOf(user)");
        assertApproxEqAbs(ERC20(ST_ETH).balanceOf(RECEIVER), expectedUnwrappedAmount, 2, "stEth.balanceOf(RECEIVER)");
    }

    function _mintStEth(uint256 amount, address user) internal returns (uint256 stEthAmount) {
        vm.deal(user, amount);
        vm.prank(user);
        stEthAmount = IStEth(ST_ETH).submit{value: amount}(address(0));
        vm.assume(stEthAmount != 0);
    }

    function _getPermit2Data(address token, uint256 privateKey, address user) internal view returns (bytes memory) {
        privateKey = bound(privateKey, 1, type(uint160).max);

        (,, uint48 nonce) = Permit2Lib.PERMIT2.allowance(user, token, address(bundler));
        bytes32 hashed = ECDSA.toTypedDataHash(
            Permit2Lib.PERMIT2.DOMAIN_SEPARATOR(),
            PermitHash.hash(
                IAllowanceTransfer.PermitSingle({
                    details: IAllowanceTransfer.PermitDetails({
                        token: token,
                        amount: type(uint160).max,
                        expiration: type(uint48).max,
                        nonce: nonce
                    }),
                    spender: address(bundler),
                    sigDeadline: type(uint48).max
                })
            )
        );

        Signature memory signature;
        (signature.v, signature.r, signature.s) = vm.sign(privateKey, hashed);

        return abi.encodeCall(Permit2Bundler.approve2, (token, type(uint160).max, type(uint48).max, signature));
    }

    function _getAddressFromPrivateKey(uint256 privateKey) internal view returns (address user) {
        user = vm.addr(privateKey);
        vm.assume(ERC20(ST_ETH).balanceOf(user) == 0);
        vm.assume(ERC20(WST_ETH).balanceOf(user) == 0);
    }

    function _approvePermit2(address user) internal {
        vm.startPrank(user);
        ERC20(ST_ETH).approve(address(Permit2Lib.PERMIT2), type(uint256).max);
        ERC20(WST_ETH).approve(address(Permit2Lib.PERMIT2), type(uint256).max);
        vm.stopPrank();
    }
}
