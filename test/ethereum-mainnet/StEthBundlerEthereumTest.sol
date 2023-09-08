// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {SigUtils} from "test/helpers/SigUtils.sol";
import {ErrorsLib as BulkerErrorsLib} from "contracts/libraries/ErrorsLib.sol";

import {IAllowanceTransfer} from "@permit2/interfaces/IAllowanceTransfer.sol";
import {IStEth} from "contracts/ethereum-mainnet/interfaces/IStEth.sol";
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
    }

    function testTransferStEthSharesFromZeroAmount() public {
        bytes[] memory data = new bytes[](1);
        data[0] = abi.encodeCall(StEthBundler.transferSharesFrom, (0));

        vm.prank(USER);
        vm.expectRevert(bytes(BulkerErrorsLib.ZERO_AMOUNT));
        bundler.multicall(block.timestamp, data);
    }

    function testTransferStEthSharesFrom(uint256 amount, uint256 privateKey) public {
        amount = bound(amount, MIN_AMOUNT, MAX_AMOUNT);
        privateKey = bound(privateKey, 1, type(uint160).max);

        address user = _getAddressFromPrivateKey(privateKey);
        _approvePermit2(user);

        uint256 stEthAmount = _mintStEth(amount, user);
        uint256 stEthUserBalanceBeforeTransfer = ERC20(ST_ETH).balanceOf(user);

        bytes[] memory data = new bytes[](2);
        data[0] = _getPermit2Data(ST_ETH, privateKey, user);
        data[1] = abi.encodeCall(StEthBundler.transferSharesFrom, (stEthAmount));

        vm.prank(user);
        bundler.multicall(block.timestamp, data);

        assertEq(ERC20(ST_ETH).balanceOf(user), 0, "User's StEth Balance");
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

    function testWrapStEth(uint256 amount, uint256 privateKey) public {
        amount = bound(amount, MIN_AMOUNT, MAX_AMOUNT);
        privateKey = bound(privateKey, 1, type(uint160).max);

        address user = _getAddressFromPrivateKey(privateKey);
        _approvePermit2(user);

        uint256 stEthAmount = _mintStEth(amount, user);

        bytes[] memory data = new bytes[](3);
        data[0] = _getPermit2Data(ST_ETH, privateKey, user);
        data[1] = abi.encodeCall(StEthBundler.transferSharesFrom, (stEthAmount));
        data[2] = abi.encodeCall(StEthBundler.wrapStEth, (amount, RECEIVER));

        uint256 wstEthExpectedAmount = IStEth(ST_ETH).getSharesByPooledEth(amount);

        vm.prank(user);
        bundler.multicall(block.timestamp, data);

        assertEq(ERC20(WST_ETH).balanceOf(address(bundler)), 0, "Bundler's wrapped stEth balance");
        assertEq(ERC20(WST_ETH).balanceOf(user), 0, "User's wrapped stEth balance");
        assertEq(ERC20(WST_ETH).balanceOf(RECEIVER), wstEthExpectedAmount, "Receiver's wrapped stEth balance");

        assertEq(ERC20(ST_ETH).balanceOf(address(bundler)), 0, "Bundler's stEth balance");
        assertEq(ERC20(ST_ETH).balanceOf(user), 0, "User's stEth balance");
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

    function testUnwrapWstEth(uint256 amount, uint256 privateKey) public {
        amount = bound(amount, MIN_AMOUNT, MAX_AMOUNT);
        privateKey = bound(privateKey, 1, type(uint160).max);

        address user = _getAddressFromPrivateKey(privateKey);
        _approvePermit2(user);

        bytes[] memory data = new bytes[](3);
        data[0] = _getPermit2Data(WST_ETH, privateKey, user);
        data[1] = abi.encodeCall(ERC20Bundler.transferFrom2, (WST_ETH, amount));
        data[2] = abi.encodeCall(StEthBundler.unwrapStEth, (amount, RECEIVER));

        deal(WST_ETH, user, amount);
        vm.prank(user);
        bundler.multicall(block.timestamp, data);

        uint256 expectedUnwrappedAmount = IWStEth(WST_ETH).getStETHByWstETH(amount);

        assertEq(ERC20(WST_ETH).balanceOf(address(bundler)), 0, "Bundler's wrapped stEth balance");
        assertEq(ERC20(WST_ETH).balanceOf(user), 0, "User's wrapped stEth balance");
        assertEq(ERC20(WST_ETH).balanceOf(RECEIVER), 0, "Receiver's wrapped stEth balance");

        assertEq(ERC20(ST_ETH).balanceOf(address(bundler)), 0, "Bundler's stEth balance");
        assertEq(ERC20(ST_ETH).balanceOf(user), 0, "User's stEth balance");
        assertApproxEqAbs(ERC20(ST_ETH).balanceOf(RECEIVER), expectedUnwrappedAmount, 2, "Receiver's stEth balance");
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

        return abi.encodeCall(ERC20Bundler.approve2, (token, type(uint160).max, type(uint48).max, signature));
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

    function testTransferStEthAmount(uint256 amount) public {
        amount = bound(amount, MIN_AMOUNT, MAX_AMOUNT);

        uint256 stEthAmount = _mintStEth(amount, USER);
        console2.log(stEthAmount, "stEthAmount");

        uint256 balance = ERC20(ST_ETH).balanceOf(USER);
        console2.log(balance, "balance");

        bytes[] memory data = new bytes[](3);
        data[0] = abi.encodeCall(ERC20Bundler.transferFrom2, (ST_ETH, amount));

        vm.startPrank(USER);
        ERC20(ST_ETH).approve(address(bundler), type(uint256).max);
        bundler.multicall(block.timestamp, data);
        vm.stopPrank();

        uint256 bundlerBalance  = ERC20(ST_ETH).balanceOf(address(bundler));
        uint256 userBalance = ERC20(ST_ETH).balanceOf(USER);

        console2.log(bundlerBalance, "bundlerBalance");
        console2.log(userBalance, "userBalance");

        assertEq(bundlerBalance, balance, "bundler's balance");
        assertEq(userBalance, 0, "user's balance");
    }
}
