// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {IAllowanceTransfer} from "@permit2/interfaces/IAllowanceTransfer.sol";

import {ErrorsLib} from "src/libraries/ErrorsLib.sol";

import "src/mocks/bundlers/ethereum/EthereumStEthBundlerMock.sol";

import "./helpers/EthereumTest.sol";

contract EthereumStEthBundlerEthereumTest is EthereumTest {
    function setUp() public override {
        super.setUp();

        bundler = new EthereumStEthBundlerMock();
    }

    function testStakeEth(uint256 amount) public {
        amount = bound(amount, MIN_AMOUNT, 10_000 ether);

        deal(USER, amount);

        bundle.push(abi.encodeCall(StEthBundler.stakeEth, (amount, address(0))));
        bundle.push(_erc20Transfer(ST_ETH, RECEIVER, type(uint256).max));

        vm.prank(USER);
        bundler.multicall{value: amount}(bundle);

        assertEq(USER.balance, 0, "USER.balance");
        assertEq(RECEIVER.balance, 0, "RECEIVER.balance");
        assertEq(address(bundler).balance, 0, "bundler.balance");
        assertEq(ERC20(ST_ETH).balanceOf(USER), 0, "balanceOf(USER)");
        assertApproxEqAbs(ERC20(ST_ETH).balanceOf(address(bundler)), 0, 1, "balanceOf(bundler)");
        assertApproxEqAbs(ERC20(ST_ETH).balanceOf(RECEIVER), amount, 3, "balanceOf(RECEIVER)");
    }

    function testWrapZeroAmount() public {
        bundle.push(abi.encodeCall(StEthBundler.wrapStEth, (0)));

        vm.expectRevert(bytes(ErrorsLib.ZERO_AMOUNT));
        vm.prank(USER);
        bundler.multicall(bundle);
    }

    function testWrapStEth(uint256 amount, uint256 privateKey) public {
        amount = bound(amount, MIN_AMOUNT, MAX_AMOUNT);
        privateKey = bound(privateKey, 1, type(uint160).max);

        address user = _getAddressFromPrivateKey(privateKey);
        _approvePermit2(user);

        deal(ST_ETH, user, amount);

        amount = ERC20(ST_ETH).balanceOf(user);

        bundle.push(_getPermit2Data(ST_ETH, privateKey, user));
        bundle.push(abi.encodeCall(Permit2Bundler.transferFrom2, (ST_ETH, amount)));
        bundle.push(abi.encodeCall(StEthBundler.wrapStEth, (amount)));
        bundle.push(_erc20Transfer(WST_ETH, RECEIVER, type(uint256).max));

        uint256 wstEthExpectedAmount = IStEth(ST_ETH).getSharesByPooledEth(ERC20(ST_ETH).balanceOf(user));

        vm.prank(user);
        bundler.multicall(bundle);

        assertEq(ERC20(WST_ETH).balanceOf(address(bundler)), 0, "wstEth.balanceOf(bundler)");
        assertEq(ERC20(WST_ETH).balanceOf(user), 0, "wstEth.balanceOf(user)");
        assertApproxEqAbs(ERC20(WST_ETH).balanceOf(RECEIVER), wstEthExpectedAmount, 1, "wstEth.balanceOf(RECEIVER)");

        assertApproxEqAbs(ERC20(ST_ETH).balanceOf(address(bundler)), 0, 1, "wstEth.balanceOf(bundler)");
        assertApproxEqAbs(ERC20(ST_ETH).balanceOf(user), 0, 1, "wstEth.balanceOf(user)");
        assertEq(ERC20(ST_ETH).balanceOf(RECEIVER), 0, "wstEth.balanceOf(RECEIVER)");
    }

    function testUnwrapZeroAmount() public {
        bundle.push(abi.encodeCall(StEthBundler.unwrapStEth, (0)));

        vm.expectRevert(bytes(ErrorsLib.ZERO_AMOUNT));
        vm.prank(USER);
        bundler.multicall(bundle);
    }

    function testUnwrapWstEth(uint256 amount, uint256 privateKey) public {
        amount = bound(amount, MIN_AMOUNT, MAX_AMOUNT);
        privateKey = bound(privateKey, 1, type(uint160).max);

        address user = _getAddressFromPrivateKey(privateKey);
        _approvePermit2(user);

        bundle.push(_getPermit2Data(WST_ETH, privateKey, user));
        bundle.push(abi.encodeCall(Permit2Bundler.transferFrom2, (WST_ETH, amount)));
        bundle.push(abi.encodeCall(StEthBundler.unwrapStEth, (amount)));
        bundle.push(_erc20Transfer(ST_ETH, RECEIVER, type(uint256).max));

        deal(WST_ETH, user, amount);
        vm.prank(user);
        bundler.multicall(bundle);

        uint256 expectedUnwrappedAmount = IWstEth(WST_ETH).getStETHByWstETH(amount);

        assertEq(ERC20(WST_ETH).balanceOf(address(bundler)), 0, "wstEth.balanceOf(bundler)");
        assertEq(ERC20(WST_ETH).balanceOf(user), 0, "wstEth.balanceOf(user)");
        assertEq(ERC20(WST_ETH).balanceOf(RECEIVER), 0, "wstEth.balanceOf(RECEIVER)");

        assertApproxEqAbs(ERC20(ST_ETH).balanceOf(address(bundler)), 0, 1, "stEth.balanceOf(bundler)");
        assertEq(ERC20(ST_ETH).balanceOf(user), 0, "stEth.balanceOf(user)");
        assertApproxEqAbs(ERC20(ST_ETH).balanceOf(RECEIVER), expectedUnwrappedAmount, 3, "stEth.balanceOf(RECEIVER)");
    }

    function _getPermit2Data(address token, uint256 privateKey, address user) internal view returns (bytes memory) {
        (,, uint48 nonce) = Permit2Lib.PERMIT2.allowance(user, token, address(bundler));
        bytes32 hashed = SigUtils.toTypedDataHash(
            Permit2Lib.PERMIT2.DOMAIN_SEPARATOR(),
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
        );

        Signature memory signature;
        (signature.v, signature.r, signature.s) = vm.sign(privateKey, hashed);

        return abi.encodeCall(Permit2Bundler.approve2, (token, type(uint160).max, type(uint48).max, signature, false));
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
