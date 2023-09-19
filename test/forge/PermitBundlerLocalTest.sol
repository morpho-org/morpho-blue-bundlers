// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {ErrorsLib} from "contracts/libraries/ErrorsLib.sol";
import {SigUtils, Permit} from "test/forge/helpers/SigUtils.sol";
import {Permit2Bundler} from "contracts/Permit2Bundler.sol";

import "contracts/mocks/bundlers/PermitBundlerMock.sol";
import {IERC20Permit} from "@openzeppelin/token/ERC20/extensions/IERC20Permit.sol";
import {ERC20PermitMock} from "contracts/mocks/ERC20PermitMock.sol";

import "./helpers/LocalTest.sol";

contract PermitBundlerLocalTest is LocalTest {
    using SigUtils for Permit;

    PermitBundlerMock internal bundler;
    ERC20PermitMock internal permitToken;

    bytes[] internal bundle;

    function setUp() public override {
        super.setUp();

        permitToken = new ERC20PermitMock("Permit Token", "PT");
        bundler = new PermitBundlerMock();
    }

    function testPermitZeroAmount(uint256 deadline) public {
        deadline = bound(deadline, block.timestamp, type(uint48).max);

        bundle.push(
            abi.encodeCall(PermitBundler.permit, (address(permitToken), 0, deadline, Signature({v: 0, r: 0, s: 0})))
        );

        vm.expectRevert(bytes(ErrorsLib.ZERO_AMOUNT));
        bundler.multicall(block.timestamp, bundle);
    }

    function testPermitTransfer(uint256 amount, uint256 privateKey, uint256 deadline) public {
        amount = bound(amount, MIN_AMOUNT, MAX_AMOUNT);
        deadline = bound(deadline, block.timestamp, type(uint48).max);
        privateKey = bound(privateKey, 1, type(uint160).max);

        address user = vm.addr(privateKey);

        bundle.push(_getPermitData(address(permitToken), privateKey, user, amount, deadline));
        bundle.push(abi.encodeCall(Permit2Bundler.transferFrom2, (address(permitToken), amount)));

        permitToken.setBalance(user, amount);

        vm.prank(user);
        bundler.multicall(block.timestamp, bundle);

        assertEq(permitToken.balanceOf(address(bundler)), amount, "permitToken.balanceOf(bundler)");
        assertEq(permitToken.balanceOf(user), 0, "permitToken.balanceOf(USER)");
    }

    function _getPermitData(address token, uint256 privateKey, address user, uint256 amount, uint256 deadline)
        internal
        view
        returns (bytes memory)
    {
        uint256 nonce = IERC20Permit(token).nonces(user);
        bytes32 domainSeparator = IERC20Permit(token).DOMAIN_SEPARATOR();

        Permit memory permit = Permit(user, address(bundler), amount, nonce, deadline);
        bytes32 hashed = permit.getPermitTypedDataHash(domainSeparator);

        Signature memory signature;
        (signature.v, signature.r, signature.s) = vm.sign(privateKey, hashed);

        return abi.encodeCall(PermitBundler.permit, (address(permitToken), amount, deadline, signature));
    }
}
