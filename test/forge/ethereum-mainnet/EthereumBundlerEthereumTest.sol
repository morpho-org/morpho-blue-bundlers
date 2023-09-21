// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {IAllowanceTransfer} from "@permit2/interfaces/IAllowanceTransfer.sol";

import {ECDSA} from "@openzeppelin/utils/cryptography/ECDSA.sol";

import "contracts/ethereum-mainnet/EthereumBundler.sol";
import {MorphoBundler} from "contracts/MorphoBundler.sol";
import {Permit2Bundler} from "contracts/Permit2Bundler.sol";

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
        bundle.push(Call(abi.encodeCall(Permit2Bundler.transferFrom2, (marketParams.borrowableToken, amount)), false));
        bundle.push(Call(abi.encodeCall(MorphoBundler.morphoSupply, (marketParams, amount, 0, onBehalf, hex"")), false));

        uint256 collateralBalanceBefore = ERC20(marketParams.collateralToken).balanceOf(onBehalf);
        uint256 borrowableBalanceBefore = ERC20(marketParams.borrowableToken).balanceOf(onBehalf);

        _deal(marketParams.borrowableToken, user, amount);

        vm.startPrank(user);
        ERC20(marketParams.borrowableToken).safeApprove(address(Permit2Lib.PERMIT2), type(uint256).max);
        ERC20(marketParams.collateralToken).safeApprove(address(Permit2Lib.PERMIT2), type(uint256).max);

        bundler.multicall(deadline, bundle);
        vm.stopPrank();

        assertEq(ERC20(marketParams.collateralToken).balanceOf(user), 0, "collateral.balanceOf(user)");
        assertEq(ERC20(marketParams.borrowableToken).balanceOf(user), 0, "borrowable.balanceOf(user)");

        assertEq(
            ERC20(marketParams.collateralToken).balanceOf(onBehalf),
            collateralBalanceBefore,
            "collateral.balanceOf(onBehalf)"
        );
        assertEq(
            ERC20(marketParams.borrowableToken).balanceOf(onBehalf),
            borrowableBalanceBefore,
            "borrowable.balanceOf(onBehalf)"
        );

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
