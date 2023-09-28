// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {IAllowanceTransfer} from "@permit2/interfaces/IAllowanceTransfer.sol";
import {SignatureVerification} from "@permit2/libraries/SignatureVerification.sol";

import {ErrorsLib} from "src/libraries/ErrorsLib.sol";

import "src/mocks/bundlers/Permit2BundlerMock.sol";

import "./helpers/EthereumTest.sol";

contract Permit2BundlerEthereumTest is EthereumTest {
    Permit2BundlerMock internal bundler;

    function setUp() public override {
        super.setUp();

        bundler = new Permit2BundlerMock();
    }

    function testApprove2(uint256 seed, uint256 privateKey, uint256 deadline, uint256 amount) public {
        privateKey = bound(privateKey, 1, type(uint160).max);
        deadline = bound(deadline, block.timestamp, type(uint48).max);
        amount = bound(amount, MIN_AMOUNT, MAX_AMOUNT);

        address user = vm.addr(privateKey);
        MarketParams memory marketParams = _randomMarketParams(seed);

        bundle.push(_approve2Call(marketParams, privateKey, amount, deadline, false));
        bundle.push(_approve2Call(marketParams, privateKey, amount, deadline, true));

        vm.prank(user);
        bundler.multicall(block.timestamp, bundle);

        (uint160 permit2Allowance,,) = Permit2Lib.PERMIT2.allowance(user, marketParams.loanToken, address(bundler));

        assertEq(permit2Allowance, amount, "PERMIT2.allowance(user, bundler)");
        assertEq(ERC20(marketParams.loanToken).allowance(user, address(bundler)), 0, "loan.allowance(user, bundler)");
    }

    function testApprove2Revert(uint256 seed, uint256 privateKey, uint256 deadline, uint256 amount) public {
        privateKey = bound(privateKey, 1, type(uint160).max);
        deadline = bound(deadline, block.timestamp, type(uint48).max);
        amount = bound(amount, MIN_AMOUNT, MAX_AMOUNT);

        address user = vm.addr(privateKey);
        MarketParams memory marketParams = _randomMarketParams(seed);

        bundle.push(_approve2Call(marketParams, privateKey, amount, deadline, false));
        bundle.push(_approve2Call(marketParams, privateKey, amount, deadline, false));

        vm.prank(user);
        vm.expectRevert(SignatureVerification.InvalidSigner.selector);
        bundler.multicall(block.timestamp, bundle);
    }

    function testApprove2Zero(uint256 seed, uint256 deadline) public {
        deadline = bound(deadline, block.timestamp, type(uint48).max);

        MarketParams memory marketParams = _randomMarketParams(seed);

        bundle.push(
            abi.encodeCall(
                Permit2Bundler.approve2, (marketParams.loanToken, 0, deadline, Signature({v: 0, r: 0, s: 0}), false)
            )
        );

        vm.expectRevert(bytes(ErrorsLib.ZERO_AMOUNT));
        bundler.multicall(block.timestamp, bundle);
    }

    function testTransferFrom2ZeroAmount() public {
        bundle.push(abi.encodeCall(Permit2Bundler.transferFrom2, (DAI, 0)));

        vm.expectRevert(bytes(ErrorsLib.ZERO_AMOUNT));
        bundler.multicall(block.timestamp, bundle);
    }

    function _approve2Call(
        MarketParams memory marketParams,
        uint256 privateKey,
        uint256 amount,
        uint256 deadline,
        bool skipRevert
    ) internal view returns (bytes memory) {
        address user = vm.addr(privateKey);

        (,, uint48 nonce) = Permit2Lib.PERMIT2.allowance(user, marketParams.loanToken, address(bundler));
        bytes32 digest = SigUtils.toTypedDataHash(
            Permit2Lib.PERMIT2.DOMAIN_SEPARATOR(),
            IAllowanceTransfer.PermitSingle({
                details: IAllowanceTransfer.PermitDetails({
                    token: marketParams.loanToken,
                    amount: uint160(amount),
                    expiration: type(uint48).max,
                    nonce: nonce
                }),
                spender: address(bundler),
                sigDeadline: deadline
            })
        );

        Signature memory signature;
        (signature.v, signature.r, signature.s) = vm.sign(privateKey, digest);

        return
            abi.encodeCall(Permit2Bundler.approve2, (marketParams.loanToken, amount, deadline, signature, skipRevert));
    }
}
