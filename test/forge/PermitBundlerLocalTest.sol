// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {SigUtils, Permit} from "test/forge/helpers/SigUtils.sol";

import "src/mocks/bundlers/PermitBundlerMock.sol";
import {ERC20PermitMock} from "src/mocks/ERC20PermitMock.sol";

import "./helpers/LocalTest.sol";

contract PermitBundlerLocalTest is LocalTest {
    ERC20PermitMock internal permitToken;

    function setUp() public override {
        super.setUp();

        bundler = new PermitBundlerMock();

        permitToken = new ERC20PermitMock("Permit Token", "PT");
    }

    function testPermit(uint256 amount, uint256 privateKey, uint256 deadline) public {
        amount = bound(amount, MIN_AMOUNT, MAX_AMOUNT);
        deadline = bound(deadline, block.timestamp, type(uint48).max);
        privateKey = bound(privateKey, 1, type(uint160).max);

        address user = vm.addr(privateKey);

        bundle.push(_permitCall(permitToken, privateKey, amount, deadline, false));
        bundle.push(_permitCall(permitToken, privateKey, amount, deadline, true));

        vm.prank(user);
        bundler.multicall(bundle);

        assertEq(permitToken.allowance(user, address(bundler)), amount, "allowance(user, bundler)");
    }

    function testPermitRevert(uint256 amount, uint256 privateKey, uint256 deadline) public {
        amount = bound(amount, MIN_AMOUNT, MAX_AMOUNT);
        deadline = bound(deadline, block.timestamp, type(uint48).max);
        privateKey = bound(privateKey, 1, type(uint160).max);

        address user = vm.addr(privateKey);

        bundle.push(_permitCall(permitToken, privateKey, amount, deadline, false));
        bundle.push(_permitCall(permitToken, privateKey, amount, deadline, false));

        vm.prank(user);
        vm.expectRevert("ERC20Permit: invalid signature");
        bundler.multicall(bundle);
    }

    function testTransferFrom(uint256 amount, uint256 privateKey, uint256 deadline) public {
        amount = bound(amount, MIN_AMOUNT, MAX_AMOUNT);
        deadline = bound(deadline, block.timestamp, type(uint48).max);
        privateKey = bound(privateKey, 1, type(uint160).max);

        address user = vm.addr(privateKey);

        bundle.push(_permitCall(permitToken, privateKey, amount, deadline, false));
        bundle.push(abi.encodeCall(BaseBundler.erc20TransferFrom, (address(permitToken), amount)));

        permitToken.setBalance(user, amount);

        vm.prank(user);
        bundler.multicall(bundle);

        assertEq(permitToken.balanceOf(address(bundler)), amount, "balanceOf(bundler)");
        assertEq(permitToken.balanceOf(user), 0, "balanceOf(user)");
    }

    function _permitCall(IERC20Permit token, uint256 privateKey, uint256 amount, uint256 deadline, bool skipRevert)
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
