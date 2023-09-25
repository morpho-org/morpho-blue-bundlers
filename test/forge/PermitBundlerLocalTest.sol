// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {SigUtils, Permit} from "test/forge/helpers/SigUtils.sol";

import "src/mocks/bundlers/PermitBundlerMock.sol";
import {ERC20PermitMock} from "src/mocks/ERC20PermitMock.sol";

import "./helpers/LocalTest.sol";

contract PermitBundlerLocalTest is LocalTest {
    PermitBundlerMock internal bundler;
    ERC20PermitMock internal permitToken;

    function setUp() public override {
        super.setUp();

        permitToken = new ERC20PermitMock("Permit Token", "PT");
        bundler = new PermitBundlerMock();
    }

    function testPermitAllowance(uint256 amount, uint256 privateKey, uint256 deadline) public {
        amount = bound(amount, MIN_AMOUNT, MAX_AMOUNT);
        deadline = bound(deadline, block.timestamp, type(uint48).max);
        privateKey = bound(privateKey, 1, type(uint160).max);

        address user = vm.addr(privateKey);

        bundle.push(_getPermitData(address(permitToken), privateKey, user, amount, deadline));

        vm.prank(user);
        bundler.multicall(block.timestamp, bundle);

        assertEq(permitToken.allowance(user, address(bundler)), amount, "permitToken.allowance(user, address(bundler))");
    }

    function testPermitTransferFrom(uint256 amount, uint256 privateKey, uint256 deadline) public {
        amount = bound(amount, MIN_AMOUNT, MAX_AMOUNT);
        deadline = bound(deadline, block.timestamp, type(uint48).max);
        privateKey = bound(privateKey, 1, type(uint160).max);

        address user = vm.addr(privateKey);

        bundle.push(_getPermitData(address(permitToken), privateKey, user, amount, deadline));
        bundle.push(abi.encodeCall(BaseBundler.transferFrom, (address(permitToken), amount)));

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

        Permit memory permit = Permit(user, address(bundler), amount, nonce, deadline);

        bytes32 digest = SigUtils.toTypedDataHash(IERC20Permit(token).DOMAIN_SEPARATOR(), permit);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, digest);

        return abi.encodeCall(PermitBundler.permit, (token, amount, deadline, v, r, s));
    }
}
