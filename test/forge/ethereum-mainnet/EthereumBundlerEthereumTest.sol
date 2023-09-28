// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {IAllowanceTransfer} from "@permit2/interfaces/IAllowanceTransfer.sol";

import "src/ethereum-mainnet/EthereumBundler.sol";

import "./helpers/EthereumTest.sol";

contract EthereumBundlerEthereumTest is EthereumTest {
    using MathLib for uint256;
    using MorphoLib for IMorpho;
    using MorphoBalancesLib for IMorpho;
    using MarketParamsLib for MarketParams;
    using SafeTransferLib for ERC20;

    EthereumBundler private bundler;

    function setUp() public override {
        super.setUp();

        bundler = new EthereumBundler(address(morpho));

        vm.prank(USER);
        morpho.setAuthorization(address(bundler), true);
    }

    function testSupplyWithPermit2(uint256 seed, uint256 amount, address onBehalf, uint256 privateKey, uint256 deadline)
        public
    {
        vm.assume(onBehalf != address(0));
        vm.assume(onBehalf != address(morpho));
        vm.assume(onBehalf != address(bundler));

        amount = bound(amount, MIN_AMOUNT, MAX_AMOUNT);
        privateKey = bound(privateKey, 1, type(uint160).max);
        deadline = bound(deadline, block.timestamp, type(uint48).max);

        address user = vm.addr(privateKey);
        MarketParams memory marketParams = _randomMarketParams(seed);

        (,, uint48 nonce) = Permit2Lib.PERMIT2.allowance(user, marketParams.loanToken, address(bundler));
        bytes32 hashed = SigUtils.toTypedDataHash(
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
        (signature.v, signature.r, signature.s) = vm.sign(privateKey, hashed);

        bytes[] memory data = new bytes[](3);
        data[0] = abi.encodeCall(BaseBundler.approve2, (marketParams.loanToken, amount, deadline, signature, false));
        data[1] = abi.encodeCall(BaseBundler.transferFrom2, (marketParams.loanToken, amount));
        data[2] = abi.encodeCall(BaseBundler.morphoSupply, (marketParams, amount, 0, onBehalf, hex""));

        uint256 collateralBalanceBefore = ERC20(marketParams.collateralToken).balanceOf(onBehalf);
        uint256 loanBalanceBefore = ERC20(marketParams.loanToken).balanceOf(onBehalf);

        _deal(marketParams.loanToken, user, amount);

        vm.startPrank(user);
        ERC20(marketParams.loanToken).safeApprove(address(Permit2Lib.PERMIT2), type(uint256).max);
        ERC20(marketParams.collateralToken).safeApprove(address(Permit2Lib.PERMIT2), type(uint256).max);

        bundler.multicall(deadline, data);
        vm.stopPrank();

        assertEq(ERC20(marketParams.collateralToken).balanceOf(user), 0, "collateral.balanceOf(user)");
        assertEq(ERC20(marketParams.loanToken).balanceOf(user), 0, "loan.balanceOf(user)");

        assertEq(
            ERC20(marketParams.collateralToken).balanceOf(onBehalf),
            collateralBalanceBefore,
            "collateral.balanceOf(onBehalf)"
        );
        assertEq(ERC20(marketParams.loanToken).balanceOf(onBehalf), loanBalanceBefore, "loan.balanceOf(onBehalf)");

        Id id = marketParams.id();

        assertEq(morpho.collateral(id, onBehalf), 0, "collateral(onBehalf)");
        assertEq(morpho.supplyShares(id, onBehalf), amount * SharesMathLib.VIRTUAL_SHARES, "supplyShares(onBehalf)");
        assertEq(morpho.borrowShares(id, onBehalf), 0, "borrowShares(onBehalf)");

        if (onBehalf != user) {
            assertEq(morpho.collateral(id, user), 0, "collateral(user)");
            assertEq(morpho.supplyShares(id, user), 0, "supplyShares(user)");
            assertEq(morpho.borrowShares(id, user), 0, "borrowShares(user)");
        }
    }
}
