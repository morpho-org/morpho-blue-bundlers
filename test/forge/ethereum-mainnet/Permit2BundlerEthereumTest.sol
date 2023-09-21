// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {IAllowanceTransfer} from "@permit2/interfaces/IAllowanceTransfer.sol";

import {ErrorsLib} from "contracts/libraries/ErrorsLib.sol";
import {ECDSA} from "@openzeppelin/utils/cryptography/ECDSA.sol";

import "contracts/mocks/bundlers/Permit2BundlerMock.sol";

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

        (,, uint48 nonce) = Permit2Lib.PERMIT2.allowance(user, marketParams.borrowableToken, address(bundler));
        bytes32 hashed = ECDSA.toTypedDataHash(
            Permit2Lib.PERMIT2.DOMAIN_SEPARATOR(),
            PermitHash.hash(
                IAllowanceTransfer.PermitSingle({
                    details: IAllowanceTransfer.PermitDetails({
                        token: marketParams.borrowableToken,
                        amount: uint160(amount),
                        expiration: type(uint48).max,
                        nonce: nonce
                    }),
                    spender: address(bundler),
                    sigDeadline: deadline
                })
            )
        );

        Signature memory signature;
        (signature.v, signature.r, signature.s) = vm.sign(privateKey, hashed);

        bundle.push(
            Call(
                abi.encodeCall(Permit2Bundler.approve2, (marketParams.borrowableToken, amount, deadline, signature)),
                false
            )
        );

        vm.prank(user);
        bundler.multicall(block.timestamp, bundle);

        (uint160 permit2Allowance,,) =
            Permit2Lib.PERMIT2.allowance(user, marketParams.borrowableToken, address(bundler));

        assertEq(permit2Allowance, amount, "PERMIT2.allowance(user, bundler)");
        assertEq(
            ERC20(marketParams.borrowableToken).allowance(user, address(bundler)),
            0,
            "borrowable.allowance(user, bundler)"
        );
    }

    function testApprove2Zero(uint256 seed, uint256 deadline) public {
        deadline = bound(deadline, block.timestamp, type(uint48).max);

        MarketParams memory marketParams = _randomMarketParams(seed);

        bundle.push(
            Call(
                abi.encodeCall(
                    Permit2Bundler.approve2, (marketParams.borrowableToken, 0, deadline, Signature({v: 0, r: 0, s: 0}))
                ),
                false
            )
        );

        vm.expectRevert(bytes(ErrorsLib.ZERO_AMOUNT));
        bundler.multicall(block.timestamp, bundle);
    }
}
