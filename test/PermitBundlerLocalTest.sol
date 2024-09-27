// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {SigUtils, Permit} from "./helpers/SigUtils.sol";

import {ErrorsLib} from "../src/libraries/ErrorsLib.sol";
import {IERC20Permit} from "../lib/openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Permit.sol";
import {ERC20PermitMock} from "../src/mocks/ERC20PermitMock.sol";

import "./helpers/LocalTest.sol";

contract PermitBundlerLocalTest is LocalTest {
    ERC20PermitMock internal permitToken;

    function setUp() public override {
        super.setUp();

        permitToken = new ERC20PermitMock("Permit Token", "PT");
    }

    function testPermit(uint256 amount, uint256 privateKey, uint256 deadline) public {
        amount = bound(amount, MIN_AMOUNT, MAX_AMOUNT);
        deadline = bound(deadline, block.timestamp, type(uint48).max);
        privateKey = bound(privateKey, 1, type(uint160).max);

        address user = vm.addr(privateKey);

        bundle.push(_permit(permitToken, privateKey, amount, deadline, false));
        bundle.push(_permit(permitToken, privateKey, amount, deadline, true));

        vm.prank(user);
        bundler.multicall(bundle);

        assertEq(permitToken.allowance(user, address(bundler)), amount, "allowance(user, bundler)");
    }

    function testPermitUninitiated(uint256 amount) public {
        amount = bound(amount, MIN_AMOUNT, MAX_AMOUNT);

        vm.expectRevert(bytes(ErrorsLib.UNINITIATED));
        PermitBundler(address(bundler)).permit(address(loanToken), amount, SIGNATURE_DEADLINE, 0, 0, 0, true);
    }

    function testPermitRevert(uint256 amount, uint256 privateKey, uint256 deadline) public {
        amount = bound(amount, MIN_AMOUNT, MAX_AMOUNT);
        deadline = bound(deadline, block.timestamp, type(uint48).max);
        privateKey = bound(privateKey, 1, type(uint160).max);

        address user = vm.addr(privateKey);

        bundle.push(_permit(permitToken, privateKey, amount, deadline, false));
        bundle.push(_permit(permitToken, privateKey, amount, deadline, false));

        vm.prank(user);
        vm.expectRevert("ERC20Permit: invalid signature");
        bundler.multicall(bundle);
    }

    function testTransferFrom(uint256 amount, uint256 privateKey, uint256 deadline) public {
        amount = bound(amount, MIN_AMOUNT, MAX_AMOUNT);
        deadline = bound(deadline, block.timestamp, type(uint48).max);
        privateKey = bound(privateKey, 1, type(uint160).max);

        address user = vm.addr(privateKey);

        bundle.push(_permit(permitToken, privateKey, amount, deadline, false));
        bundle.push(_erc20TransferFrom(address(permitToken), amount));

        permitToken.setBalance(user, amount);

        vm.prank(user);
        bundler.multicall(bundle);

        assertEq(permitToken.balanceOf(address(bundler)), amount, "balanceOf(bundler)");
        assertEq(permitToken.balanceOf(user), 0, "balanceOf(user)");
    }

    function _permit(IERC20Permit token, uint256 privateKey, uint256 amount, uint256 deadline, bool skipRevert)
        internal
        view
        returns (bytes memory)
    {
        address user = vm.addr(privateKey);

        Permit memory permit = Permit(user, address(bundler), amount, token.nonces(user), deadline);

        bytes32 digest = SigUtils.toTypedDataHash(token.DOMAIN_SEPARATOR(), permit);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, digest);

        return abi.encodeCall(PermitBundler.permit, (address(token), amount, deadline, v, r, s, skipRevert));
    }
}
