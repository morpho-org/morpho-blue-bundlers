// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {ErrorsLib} from "src/libraries/ErrorsLib.sol";

import "src/mocks/bundlers/Permit2BundlerMock.sol";

import "./helpers/EthereumTest.sol";

contract Permit2BundlerEthereumTest is EthereumTest {
    using SafeTransferLib for ERC20;

    function setUp() public override {
        super.setUp();

        bundler = new Permit2BundlerMock();
    }

    function testPermit2TransferFrom(uint256 seed, uint256 privateKey, uint256 amount) public {
        privateKey = bound(privateKey, 1, type(uint160).max);
        amount = bound(amount, MIN_AMOUNT, MAX_AMOUNT);

        address user = vm.addr(privateKey);
        MarketParams memory marketParams = _randomMarketParams(seed);

        deal(marketParams.loanToken, user, amount);

        bundle.push(_permit2TransferFrom(privateKey, marketParams.loanToken, amount, 0));

        vm.startPrank(user);
        ERC20(marketParams.loanToken).safeApprove(address(Permit2Lib.PERMIT2), type(uint256).max);

        bundler.multicall(bundle);
        vm.stopPrank();

        (uint160 permit2Allowance,,) = Permit2Lib.PERMIT2.allowance(user, marketParams.loanToken, address(bundler));

        assertEq(permit2Allowance, 0, "PERMIT2.allowance(user, bundler)");
        assertEq(ERC20(marketParams.loanToken).allowance(user, address(bundler)), 0, "loan.allowance(user, bundler)");
        assertEq(ERC20(marketParams.loanToken).balanceOf(address(bundler)), amount, "loan.balanceOf(bundler)");
    }

    function testPermit2TransferFromZeroAmount(uint256 seed, uint256 privateKey, uint256 amount) public {
        privateKey = bound(privateKey, 1, type(uint160).max);
        amount = bound(amount, MIN_AMOUNT, MAX_AMOUNT);

        address user = vm.addr(privateKey);
        MarketParams memory marketParams = _randomMarketParams(seed);

        bundle.push(_permit2TransferFrom(privateKey, marketParams.loanToken, amount, 0));

        vm.prank(user);
        vm.expectRevert(bytes(ErrorsLib.ZERO_AMOUNT));
        bundler.multicall(bundle);
    }
}
