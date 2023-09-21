// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {SigUtils} from "./helpers/SigUtils.sol";
import {ErrorsLib} from "contracts/libraries/ErrorsLib.sol";
import {ECDSA} from "@openzeppelin/utils/cryptography/ECDSA.sol";

import {BaseBundler} from "contracts/BaseBundler.sol";
import "contracts/EVMBundler.sol";

import "./helpers/LocalTest.sol";

contract EVMBundlerLocalTest is LocalTest {
    using MathLib for uint256;
    using MorphoLib for IMorpho;
    using MorphoBalancesLib for IMorpho;
    using SharesMathLib for uint256;

    uint256 internal constant SIG_DEADLINE = type(uint32).max;

    EVMBundler private bundler;

    function setUp() public override {
        super.setUp();

        bundler = new EVMBundler(address(morpho));

        vm.startPrank(USER);
        borrowableToken.approve(address(morpho), type(uint256).max);
        collateralToken.approve(address(morpho), type(uint256).max);
        borrowableToken.approve(address(bundler), type(uint256).max);
        collateralToken.approve(address(bundler), type(uint256).max);
        vm.stopPrank();

        vm.prank(LIQUIDATOR);
        borrowableToken.approve(address(bundler), type(uint256).max);
    }

    function approveERC20ToMorphoAndBundler(address user) internal {
        vm.startPrank(user);
        borrowableToken.approve(address(morpho), type(uint256).max);
        collateralToken.approve(address(morpho), type(uint256).max);
        borrowableToken.approve(address(bundler), type(uint256).max);
        collateralToken.approve(address(bundler), type(uint256).max);
        vm.stopPrank();
    }

    function _getUserAndKey(uint256 privateKey) internal returns (uint256, address) {
        privateKey = bound(privateKey, 1, type(uint32).max);
        address user = vm.addr(privateKey);
        vm.label(user, "user");
        return (privateKey, user);
    }

    function _morphoSetAuthorizationWithSigCall(
        uint256 privateKey,
        address authorized,
        bool isAuthorized,
        uint256 nonce
    ) internal view returns (bytes memory) {
        Authorization memory auth = Authorization({
            authorizer: vm.addr(privateKey),
            authorized: authorized,
            isAuthorized: isAuthorized,
            nonce: nonce,
            deadline: SIG_DEADLINE
        });

        bytes32 authorizationTypehash = keccak256(
            "Authorization(address authorizer,address authorized,bool isAuthorized,uint256 nonce,uint256 deadline)"
        );
        bytes32 digest =
            ECDSA.toTypedDataHash(morpho.DOMAIN_SEPARATOR(), keccak256(abi.encode(authorizationTypehash, auth)));

        Signature memory sig;
        (sig.v, sig.r, sig.s) = vm.sign(privateKey, digest);

        return abi.encodeCall(MorphoBundler.morphoSetAuthorizationWithSig, (auth, sig));
    }

    function assumeOnBehalf(address onBehalf) internal view {
        vm.assume(onBehalf != address(0));
        vm.assume(onBehalf != address(morpho));
        vm.assume(onBehalf != address(bundler));
    }

    function testSetAuthorizationWithSig(uint256 privateKey, uint32 deadline) public {
        privateKey = bound(privateKey, 1, type(uint32).max);
        deadline = uint32(bound(deadline, block.timestamp + 1, type(uint32).max));

        address user = vm.addr(privateKey);
        vm.assume(user != USER);

        Authorization memory authorization;
        authorization.authorizer = user;
        authorization.authorized = address(bundler);
        authorization.deadline = deadline;
        authorization.nonce = morpho.nonce(user);
        authorization.isAuthorized = true;

        bytes32 digest = SigUtils.getTypedDataHash(morpho.DOMAIN_SEPARATOR(), authorization);

        Signature memory sig;
        (sig.v, sig.r, sig.s) = vm.sign(privateKey, digest);

        bundle.push(Call(abi.encodeCall(MorphoBundler.morphoSetAuthorizationWithSig, (authorization, sig)), false));

        bundler.multicall(block.timestamp, bundle);

        assertTrue(morpho.isAuthorized(user, address(bundler)), "isAuthorized(bundler)");
    }

    function testSupplyOnBehalfBundlerAddress(uint256 assets) public {
        assets = bound(assets, MIN_AMOUNT, MAX_AMOUNT);

        bundle.push(
            Call(abi.encodeCall(MorphoBundler.morphoSupply, (marketParams, assets, 0, address(bundler), hex"")), false)
        );

        vm.expectRevert(bytes(ErrorsLib.BUNDLER_ADDRESS));
        bundler.multicall(block.timestamp, bundle);
    }

    function testSupplyCollateralOnBehalfBundlerAddress(uint256 assets) public {
        assets = bound(assets, MIN_AMOUNT, MAX_AMOUNT);

        bundle.push(
            Call(
                abi.encodeCall(MorphoBundler.morphoSupplyCollateral, (marketParams, assets, address(bundler), hex"")),
                false
            )
        );

        vm.expectRevert(bytes(ErrorsLib.BUNDLER_ADDRESS));
        bundler.multicall(block.timestamp, bundle);
    }

    function testRepayOnBehalfBundlerAddress(uint256 assets) public {
        assets = bound(assets, MIN_AMOUNT, MAX_AMOUNT);

        bundle.push(
            Call(abi.encodeCall(MorphoBundler.morphoRepay, (marketParams, assets, 0, address(bundler), hex"")), false)
        );

        vm.expectRevert(bytes(ErrorsLib.BUNDLER_ADDRESS));
        bundler.multicall(block.timestamp, bundle);
    }

    function _testSupply(uint256 amount, address onBehalf) internal {
        assertEq(collateralToken.balanceOf(USER), 0, "collateral.balanceOf(USER)");
        assertEq(borrowableToken.balanceOf(USER), 0, "borrowable.balanceOf(USER)");

        assertEq(collateralToken.balanceOf(onBehalf), 0, "collateral.balanceOf(onBehalf)");
        assertEq(borrowableToken.balanceOf(onBehalf), 0, "borrowable.balanceOf(onBehalf)");

        assertEq(morpho.collateral(id, onBehalf), 0, "collateral(onBehalf)");
        assertEq(morpho.supplyShares(id, onBehalf), amount * SharesMathLib.VIRTUAL_SHARES, "supplyShares(onBehalf)");
        assertEq(morpho.borrowShares(id, onBehalf), 0, "borrowShares(onBehalf)");

        if (onBehalf != USER) {
            assertEq(morpho.collateral(id, USER), 0, "collateral(USER)");
            assertEq(morpho.supplyShares(id, USER), 0, "supplyShares(USER)");
            assertEq(morpho.borrowShares(id, USER), 0, "borrowShares(USER)");
        }
    }

    function testSupply(uint256 amount, address onBehalf) public {
        assumeOnBehalf(onBehalf);

        amount = bound(amount, MIN_AMOUNT, MAX_AMOUNT);

        bundle.push(Call(abi.encodeCall(Permit2Bundler.transferFrom2, (address(borrowableToken), amount)), false));
        bundle.push(Call(abi.encodeCall(MorphoBundler.morphoSupply, (marketParams, amount, 0, onBehalf, hex"")), false));

        borrowableToken.setBalance(USER, amount);

        vm.prank(USER);
        bundler.multicall(block.timestamp, bundle);

        _testSupply(amount, onBehalf);
    }

    function testSupplyMax(uint256 amount, address onBehalf) public {
        assumeOnBehalf(onBehalf);

        amount = bound(amount, MIN_AMOUNT, MAX_AMOUNT);

        bundle.push(Call(abi.encodeCall(Permit2Bundler.transferFrom2, (address(borrowableToken), amount)), false));
        bundle.push(
            Call(
                abi.encodeCall(MorphoBundler.morphoSupply, (marketParams, type(uint256).max, 0, onBehalf, hex"")), false
            )
        );

        borrowableToken.setBalance(USER, amount);

        vm.prank(USER);
        bundler.multicall(block.timestamp, bundle);

        _testSupply(amount, onBehalf);
    }

    function testSupplyCallback(uint256 amount, address onBehalf) public {
        assumeOnBehalf(onBehalf);

        amount = bound(amount, MIN_AMOUNT, MAX_AMOUNT);

        bytes[] memory callbackData = new bytes[](1);
        callbackData[0] = abi.encodeCall(Permit2Bundler.transferFrom2, (address(borrowableToken), amount));

        bundle.push(
            Call(
                abi.encodeCall(
                    MorphoBundler.morphoSupply, (marketParams, amount, 0, onBehalf, abi.encode(callbackData))
                ),
                false
            )
        );

        borrowableToken.setBalance(USER, amount);

        vm.prank(USER);
        bundler.multicall(block.timestamp, bundle);

        _testSupply(amount, onBehalf);
    }

    function _testSupplyCollateral(uint256 amount, address onBehalf) internal {
        assertEq(collateralToken.balanceOf(USER), 0, "collateral.balanceOf(USER)");
        assertEq(borrowableToken.balanceOf(USER), 0, "borrowable.balanceOf(USER)");

        assertEq(collateralToken.balanceOf(onBehalf), 0, "collateral.balanceOf(onBehalf)");
        assertEq(borrowableToken.balanceOf(onBehalf), 0, "borrowable.balanceOf(onBehalf)");

        assertEq(morpho.collateral(id, onBehalf), amount, "collateral(onBehalf)");
        assertEq(morpho.supplyShares(id, onBehalf), 0, "supplyShares(onBehalf)");
        assertEq(morpho.borrowShares(id, onBehalf), 0, "borrowShares(onBehalf)");

        if (onBehalf != USER) {
            assertEq(morpho.collateral(id, USER), 0, "collateral(USER)");
            assertEq(morpho.supplyShares(id, USER), 0, "supplyShares(USER)");
            assertEq(morpho.borrowShares(id, USER), 0, "borrowShares(USER)");
        }
    }

    function testSupplyCollateral(uint256 amount, address onBehalf) public {
        assumeOnBehalf(onBehalf);

        amount = bound(amount, MIN_AMOUNT, MAX_AMOUNT);

        bundle.push(Call(abi.encodeCall(Permit2Bundler.transferFrom2, (address(collateralToken), amount)), false));
        bundle.push(
            Call(abi.encodeCall(MorphoBundler.morphoSupplyCollateral, (marketParams, amount, onBehalf, hex"")), false)
        );

        collateralToken.setBalance(USER, amount);

        vm.prank(USER);
        bundler.multicall(block.timestamp, bundle);

        _testSupplyCollateral(amount, onBehalf);
    }

    function testSupplyCollateralMax(uint256 amount, address onBehalf) public {
        assumeOnBehalf(onBehalf);

        amount = bound(amount, MIN_AMOUNT, MAX_AMOUNT);

        bundle.push(Call(abi.encodeCall(Permit2Bundler.transferFrom2, (address(collateralToken), amount)), false));
        bundle.push(
            Call(
                abi.encodeCall(MorphoBundler.morphoSupplyCollateral, (marketParams, type(uint256).max, onBehalf, hex"")),
                false
            )
        );

        collateralToken.setBalance(USER, amount);

        vm.prank(USER);
        bundler.multicall(block.timestamp, bundle);

        _testSupplyCollateral(amount, onBehalf);
    }

    function testWithdraw(uint256 privateKey, uint256 amount, uint256 withdrawnShares) public {
        address user;
        (privateKey, user) = _getUserAndKey(privateKey);
        approveERC20ToMorphoAndBundler(user);

        amount = bound(amount, MIN_AMOUNT, MAX_AMOUNT);
        uint256 expectedSupplyShares = amount.toSharesDown(0, 0);
        withdrawnShares = bound(withdrawnShares, 1, expectedSupplyShares);
        uint256 expectedWithdrawnAmount = withdrawnShares.toAssetsDown(amount, expectedSupplyShares);

        bundle.push(Call(_morphoSetAuthorizationWithSigCall(privateKey, address(bundler), true, 0), false));
        bundle.push(Call(abi.encodeCall(MorphoBundler.morphoWithdraw, (marketParams, 0, withdrawnShares, user)), false));

        borrowableToken.setBalance(user, amount);
        vm.startPrank(user);
        morpho.supply(marketParams, amount, 0, user, hex"");
        bundler.multicall(block.timestamp, bundle);
        vm.stopPrank();

        assertEq(borrowableToken.balanceOf(user), expectedWithdrawnAmount, "borrowable.balanceOf(user)");
        assertEq(borrowableToken.balanceOf(address(bundler)), 0, "borrowable.balanceOf(address(bundler))");
        assertEq(
            borrowableToken.balanceOf(address(morpho)),
            amount - expectedWithdrawnAmount,
            "borrowable.balanceOf(address(morpho))"
        );

        assertEq(morpho.collateral(id, user), 0, "collateral(user)");
        assertEq(morpho.supplyShares(id, user), expectedSupplyShares - withdrawnShares, "supplyShares(user)");
        assertEq(morpho.borrowShares(id, user), 0, "borrowShares(user)");
    }

    function _testSupplyCollateralBorrow(address user, uint256 amount, uint256 collateralAmount) internal {
        assertEq(collateralToken.balanceOf(RECEIVER), 0, "collateral.balanceOf(RECEIVER)");
        assertEq(borrowableToken.balanceOf(RECEIVER), amount, "borrowable.balanceOf(RECEIVER)");

        assertEq(morpho.collateral(id, user), collateralAmount, "collateral(user)");
        assertEq(morpho.supplyShares(id, user), 0, "supplyShares(user)");
        assertEq(morpho.borrowShares(id, user), amount * SharesMathLib.VIRTUAL_SHARES, "borrowShares(user)");

        if (RECEIVER != user) {
            assertEq(morpho.collateral(id, RECEIVER), 0, "collateral(RECEIVER)");
            assertEq(morpho.supplyShares(id, RECEIVER), 0, "supplyShares(RECEIVER)");
            assertEq(morpho.borrowShares(id, RECEIVER), 0, "borrowShares(RECEIVER)");

            assertEq(collateralToken.balanceOf(user), 0, "collateral.balanceOf(user)");
            assertEq(borrowableToken.balanceOf(user), 0, "borrowable.balanceOf(user)");
        }
    }

    function testSupplyCollateralBorrow(uint256 privateKey, uint256 amount) public {
        address user;
        (privateKey, user) = _getUserAndKey(privateKey);
        approveERC20ToMorphoAndBundler(user);

        amount = bound(amount, MIN_AMOUNT, MAX_AMOUNT);

        borrowableToken.setBalance(address(this), amount);
        morpho.supply(marketParams, amount, 0, SUPPLIER, hex"");

        uint256 collateralAmount = amount.wDivUp(LLTV);

        bundle.push(
            Call(abi.encodeCall(Permit2Bundler.transferFrom2, (address(collateralToken), collateralAmount)), false)
        );
        bundle.push(Call(_morphoSetAuthorizationWithSigCall(privateKey, address(bundler), true, 0), false));
        bundle.push(
            Call(
                abi.encodeCall(MorphoBundler.morphoSupplyCollateral, (marketParams, collateralAmount, user, hex"")),
                false
            )
        );
        bundle.push(Call(abi.encodeCall(MorphoBundler.morphoBorrow, (marketParams, amount, 0, RECEIVER)), false));

        collateralToken.setBalance(user, collateralAmount);

        vm.prank(user);
        bundler.multicall(block.timestamp, bundle);

        _testSupplyCollateralBorrow(user, amount, collateralAmount);
    }

    function testSupplyCollateralBorrowViaCallback(uint256 privateKey, uint256 amount) public {
        address user;
        (privateKey, user) = _getUserAndKey(privateKey);
        approveERC20ToMorphoAndBundler(user);

        amount = bound(amount, MIN_AMOUNT, MAX_AMOUNT);

        borrowableToken.setBalance(address(this), amount);
        morpho.supply(marketParams, amount, 0, SUPPLIER, hex"");

        uint256 collateralAmount = amount.wDivUp(LLTV);

        bytes[] memory callbackData = new bytes[](3);
        callbackData[0] = _morphoSetAuthorizationWithSigCall(privateKey, address(bundler), true, 0);
        callbackData[1] = abi.encodeCall(MorphoBundler.morphoBorrow, (marketParams, amount, 0, RECEIVER));
        callbackData[2] = abi.encodeCall(Permit2Bundler.transferFrom2, (address(collateralToken), collateralAmount));

        bundle.push(
            Call(
                abi.encodeCall(
                    MorphoBundler.morphoSupplyCollateral,
                    (marketParams, collateralAmount, user, abi.encode(callbackData))
                ),
                false
            )
        );

        collateralToken.setBalance(user, collateralAmount);

        vm.prank(user);
        bundler.multicall(block.timestamp, bundle);

        _testSupplyCollateralBorrow(user, amount, collateralAmount);
    }

    function _testRepayWithdrawCollateral(address user, uint256 collateralAmount) internal {
        assertEq(collateralToken.balanceOf(RECEIVER), collateralAmount, "collateral.balanceOf(RECEIVER)");
        assertEq(borrowableToken.balanceOf(RECEIVER), 0, "borrowable.balanceOf(RECEIVER)");

        assertEq(morpho.collateral(id, user), 0, "collateral(user)");
        assertEq(morpho.supplyShares(id, user), 0, "supplyShares(user)");
        assertEq(morpho.borrowShares(id, user), 0, "borrowShares(user)");

        if (RECEIVER != user) {
            assertEq(morpho.collateral(id, RECEIVER), 0, "collateral(RECEIVER)");
            assertEq(morpho.supplyShares(id, RECEIVER), 0, "supplyShares(RECEIVER)");
            assertEq(morpho.borrowShares(id, RECEIVER), 0, "borrowShares(RECEIVER)");

            assertEq(collateralToken.balanceOf(user), 0, "collateral.balanceOf(user)");
            assertEq(borrowableToken.balanceOf(user), 0, "borrowable.balanceOf(user)");
        }
    }

    function testRepayWithdrawCollateral(uint256 privateKey, uint256 amount) public {
        address user;
        (privateKey, user) = _getUserAndKey(privateKey);
        approveERC20ToMorphoAndBundler(user);

        amount = bound(amount, MIN_AMOUNT, MAX_AMOUNT);

        borrowableToken.setBalance(address(this), amount);
        morpho.supply(marketParams, amount, 0, SUPPLIER, hex"");

        uint256 collateralAmount = amount.wDivUp(LLTV);

        collateralToken.setBalance(user, collateralAmount);
        vm.startPrank(user);
        morpho.supplyCollateral(marketParams, collateralAmount, user, hex"");
        morpho.borrow(marketParams, amount, 0, user, user);
        vm.stopPrank();

        bundle.push(Call(abi.encodeCall(Permit2Bundler.transferFrom2, (address(borrowableToken), amount)), false));
        bundle.push(Call(_morphoSetAuthorizationWithSigCall(privateKey, address(bundler), true, 0), false));
        bundle.push(Call(abi.encodeCall(MorphoBundler.morphoRepay, (marketParams, amount, 0, user, hex"")), false));
        bundle.push(
            Call(
                abi.encodeCall(MorphoBundler.morphoWithdrawCollateral, (marketParams, collateralAmount, RECEIVER)),
                false
            )
        );

        vm.prank(user);
        bundler.multicall(block.timestamp, bundle);

        _testRepayWithdrawCollateral(user, collateralAmount);
    }

    function testRepayMaxAndWithdrawCollateral(uint256 privateKey, uint256 amount) public {
        address user;
        (privateKey, user) = _getUserAndKey(privateKey);
        approveERC20ToMorphoAndBundler(user);

        amount = bound(amount, MIN_AMOUNT, MAX_AMOUNT);

        borrowableToken.setBalance(address(this), amount);
        morpho.supply(marketParams, amount, 0, SUPPLIER, hex"");

        uint256 collateralAmount = amount.wDivUp(LLTV);

        collateralToken.setBalance(user, collateralAmount);
        vm.startPrank(user);
        morpho.supplyCollateral(marketParams, collateralAmount, user, hex"");
        morpho.borrow(marketParams, amount, 0, user, user);
        vm.stopPrank();

        bundle.push(Call(abi.encodeCall(Permit2Bundler.transferFrom2, (address(borrowableToken), amount)), false));
        bundle.push(Call(_morphoSetAuthorizationWithSigCall(privateKey, address(bundler), true, 0), false));
        bundle.push(
            Call(abi.encodeCall(MorphoBundler.morphoRepay, (marketParams, type(uint256).max, 0, user, hex"")), false)
        );
        bundle.push(
            Call(
                abi.encodeCall(MorphoBundler.morphoWithdrawCollateral, (marketParams, collateralAmount, RECEIVER)),
                false
            )
        );

        vm.prank(user);
        bundler.multicall(block.timestamp, bundle);

        _testRepayWithdrawCollateral(user, collateralAmount);
    }

    function testRepayWithdrawCollateralViaCallback(uint256 privateKey, uint256 amount) public {
        address user;
        (privateKey, user) = _getUserAndKey(privateKey);
        approveERC20ToMorphoAndBundler(user);

        amount = bound(amount, MIN_AMOUNT, MAX_AMOUNT);

        borrowableToken.setBalance(address(this), amount);
        morpho.supply(marketParams, amount, 0, SUPPLIER, hex"");

        uint256 collateralAmount = amount.wDivUp(LLTV);

        collateralToken.setBalance(user, collateralAmount);
        vm.startPrank(user);
        morpho.supplyCollateral(marketParams, collateralAmount, user, hex"");
        morpho.borrow(marketParams, amount, 0, user, user);
        vm.stopPrank();

        bytes[] memory callbackData = new bytes[](3);
        callbackBundle.push(Call(_morphoSetAuthorizationWithSigCall(privateKey, address(bundler), true, 0), false));
        callbackBundle.push(
            Call(
                abi.encodeCall(MorphoBundler.morphoWithdrawCollateral, (marketParams, collateralAmount, RECEIVER)),
                false
            )
        );
        callbackBundle.push(
            Call(abi.encodeCall(Permit2Bundler.transferFrom2, (address(borrowableToken), amount)), false)
        );

        bundle.push(
            Call(
                abi.encodeCall(MorphoBundler.morphoRepay, (marketParams, amount, 0, user, abi.encode(callbackData))),
                false
            )
        );

        vm.prank(user);
        bundler.multicall(block.timestamp, bundle);

        _testRepayWithdrawCollateral(user, collateralAmount);
    }

    function testLiquidate(uint256 amountCollateral, uint256 seizedCollateral) public {
        amountCollateral = bound(amountCollateral, MIN_AMOUNT, MAX_AMOUNT);
        uint256 amountBorrowed = amountCollateral.wMulDown(LLTV);

        borrowableToken.setBalance(USER, amountBorrowed);
        collateralToken.setBalance(USER, amountCollateral);

        vm.startPrank(USER);
        morpho.supply(marketParams, amountBorrowed, 0, USER, hex"");
        morpho.supplyCollateral(marketParams, amountCollateral, USER, hex"");
        morpho.borrow(marketParams, amountBorrowed, 0, USER, USER);
        vm.stopPrank();

        uint256 borrowShares = morpho.borrowShares(id, USER);

        oracle.setPrice(ORACLE_PRICE_SCALE / 2);
        seizedCollateral = bound(seizedCollateral, 1, amountCollateral);
        uint256 incentiveFactor = UtilsLib.min(
            MAX_LIQUIDATION_INCENTIVE_FACTOR, WAD.wDivDown(WAD - LIQUIDATION_CURSOR.wMulDown(WAD - marketParams.lltv))
        );
        uint256 repaidAssets =
            seizedCollateral.mulDivUp(ORACLE_PRICE_SCALE / 2, ORACLE_PRICE_SCALE).wDivUp(incentiveFactor);
        uint256 expectedRepaidShares = repaidAssets.toSharesDown(amountBorrowed, borrowShares);

        bundle.push(Call(abi.encodeCall(Permit2Bundler.transferFrom2, (address(borrowableToken), repaidAssets)), false));
        bundle.push(
            Call(abi.encodeCall(MorphoBundler.morphoLiquidate, (marketParams, USER, seizedCollateral, 0, hex"")), false)
        );
        bundle.push(
            Call(abi.encodeCall(BaseBundler.transfer, (address(collateralToken), LIQUIDATOR, seizedCollateral)), false)
        );

        borrowableToken.setBalance(LIQUIDATOR, repaidAssets);

        vm.prank(LIQUIDATOR);
        bundler.multicall(block.timestamp, bundle);

        assertEq(borrowableToken.balanceOf(USER), amountBorrowed, "User's borrowable token balance");
        assertEq(borrowableToken.balanceOf(LIQUIDATOR), 0, "Liquidator's borrowable token balance");
        assertEq(borrowableToken.balanceOf(address(morpho)), repaidAssets, "User's borrowable token balance");

        assertEq(collateralToken.balanceOf(USER), 0, "User's collateral token balance");
        assertEq(collateralToken.balanceOf(LIQUIDATOR), seizedCollateral, "Liquidator's collateral token balance");
        assertEq(
            collateralToken.balanceOf(address(morpho)),
            amountCollateral - seizedCollateral,
            "User's collateral token balance"
        );

        assertEq(morpho.collateral(id, USER), amountCollateral - seizedCollateral, "User's collateral on morpho");
        if (morpho.collateral(id, USER) == 0) {
            assertEq(morpho.borrowShares(id, USER), 0, "No borrow shares because of bad debt");
        } else {
            assertEq(morpho.borrowShares(id, USER), borrowShares - expectedRepaidShares, "User's borrow shares");
        }
    }

    struct BundleTransactionsVars {
        uint256 expectedSupplyShares;
        uint256 expectedBorrowShares;
        uint256 expectedTotalSupply;
        uint256 expectedTotalBorrow;
        uint256 expectedCollateral;
        uint256 expectedBundlerBorrowableBalance;
        uint256 expectedBundlerCollateralBalance;
        uint256 initialUserBorrowableBalance;
        uint256 initialUserCollateralBalance;
    }

    function testBundleTransactions(uint256 privateKey, uint256 size, uint256 seedAction, uint256 seedAmount) public {
        address user;
        (privateKey, user) = _getUserAndKey(privateKey);
        approveERC20ToMorphoAndBundler(user);
        bundle.push(Call(_morphoSetAuthorizationWithSigCall(privateKey, address(bundler), true, 0), false));

        seedAction = bound(seedAction, 0, type(uint256).max - 30);
        seedAmount = bound(seedAmount, 0, type(uint256).max - 30);

        BundleTransactionsVars memory vars;

        for (uint256 i; i < size % 30; ++i) {
            uint256 actionId = uint256(keccak256(abi.encode(seedAmount + i))) % 11;
            uint256 amount = uint256(keccak256(abi.encode(seedAction + i)));
            if (actionId < 3) _addSupplyData(vars, amount, user);
            else if (actionId < 6) _addSupplyCollateralData(vars, amount, user);
            else if (actionId < 8) _addBorrowData(vars, amount);
            else if (actionId < 9) _addRepayData(vars, amount, user);
            else if (actionId < 10) _addWithdrawData(vars, amount);
            else if (actionId == 10) _addWithdrawCollateralData(vars, amount);
        }

        borrowableToken.setBalance(user, vars.initialUserBorrowableBalance);
        collateralToken.setBalance(user, vars.initialUserCollateralBalance);

        vm.prank(user);
        bundler.multicall(block.timestamp, bundle);

        assertEq(morpho.supplyShares(id, user), vars.expectedSupplyShares, "User's supply shares");
        assertEq(morpho.borrowShares(id, user), vars.expectedBorrowShares, "User's borrow shares");
        assertEq(morpho.totalSupplyShares(id), vars.expectedSupplyShares, "Total supply shares");
        assertEq(morpho.totalBorrowShares(id), vars.expectedBorrowShares, "Total borrow shares");
        assertEq(morpho.totalSupplyAssets(id), vars.expectedTotalSupply, "Total supply");
        assertEq(morpho.totalBorrowAssets(id), vars.expectedTotalBorrow, "Total borrow");
        assertEq(morpho.collateral(id, user), vars.expectedCollateral, "User's collateral");

        assertEq(borrowableToken.balanceOf(user), 0, "User's borrowable balance");
        assertEq(collateralToken.balanceOf(user), 0, "User's collateral balance");
        assertEq(
            borrowableToken.balanceOf(address(morpho)),
            vars.expectedTotalSupply - vars.expectedTotalBorrow,
            "User's borrowable balance"
        );
        assertEq(collateralToken.balanceOf(address(morpho)), vars.expectedCollateral, "Morpho's collateral balance");
        assertEq(
            borrowableToken.balanceOf(address(bundler)),
            vars.expectedBundlerBorrowableBalance,
            "Bundler's borrowable balance"
        );
        assertEq(
            collateralToken.balanceOf(address(bundler)),
            vars.expectedBundlerCollateralBalance,
            "Bundler's collateral balance"
        );
    }

    function _getTransferData(address token, uint256 amount) internal pure returns (bytes memory data, address user) {
        data = abi.encodeCall(BaseBundler.transfer, (token, user, amount));
    }

    function _getTransferFrom2Data(address token, uint256 amount) internal pure returns (bytes memory data) {
        data = abi.encodeCall(Permit2Bundler.transferFrom2, (token, amount));
    }

    function _getSupplyData(uint256 amount, address user) internal view returns (bytes memory data) {
        data = abi.encodeCall(MorphoBundler.morphoSupply, (marketParams, amount, 0, user, hex""));
    }

    function _getSupplyCollateralData(uint256 amount, address user) internal view returns (bytes memory data) {
        data = abi.encodeCall(MorphoBundler.morphoSupplyCollateral, (marketParams, amount, user, hex""));
    }

    function _getWithdrawData(uint256 amount) internal view returns (bytes memory data) {
        data = abi.encodeCall(MorphoBundler.morphoWithdraw, (marketParams, amount, 0, address(bundler)));
    }

    function _getWithdrawCollateralData(uint256 amount) internal view returns (bytes memory data) {
        data = abi.encodeCall(MorphoBundler.morphoWithdrawCollateral, (marketParams, amount, address(bundler)));
    }

    function _getBorrowData(uint256 shares) internal view returns (bytes memory data) {
        data = abi.encodeCall(MorphoBundler.morphoBorrow, (marketParams, 0, shares, address(bundler)));
    }

    function _getRepayData(uint256 amount, address user) internal view returns (bytes memory data) {
        data = abi.encodeCall(MorphoBundler.morphoRepay, (marketParams, amount, 0, user, hex""));
    }

    function _addSupplyData(BundleTransactionsVars memory vars, uint256 amount, address user) internal {
        amount = bound(amount % MAX_AMOUNT, MIN_AMOUNT, MAX_AMOUNT);

        _transferMissingBorrowable(vars, amount);

        bundle.push(Call(_getSupplyData(amount, user), false));

        vars.expectedBundlerBorrowableBalance -= amount;

        uint256 expectedAddedSupplyShares = amount.toSharesDown(vars.expectedTotalSupply, vars.expectedSupplyShares);
        vars.expectedTotalSupply += amount;
        vars.expectedSupplyShares += expectedAddedSupplyShares;
    }

    function _addSupplyCollateralData(BundleTransactionsVars memory vars, uint256 amount, address user) internal {
        amount = bound(amount % MAX_AMOUNT, MIN_AMOUNT, MAX_AMOUNT);

        _transferMissingCollateral(vars, amount);

        bundle.push(Call(_getSupplyCollateralData(amount, user), false));

        vars.expectedBundlerCollateralBalance -= amount;

        vars.expectedCollateral += amount;
    }

    function _addWithdrawData(BundleTransactionsVars memory vars, uint256 amount) internal {
        uint256 availableLiquidity = vars.expectedTotalSupply - vars.expectedTotalBorrow;
        if (availableLiquidity == 0 || vars.expectedSupplyShares == 0) return;

        uint256 supplyBalance =
            vars.expectedSupplyShares.toAssetsDown(vars.expectedTotalSupply, vars.expectedSupplyShares);

        uint256 maxAmount = UtilsLib.min(supplyBalance, availableLiquidity);
        amount = bound(amount % maxAmount, 1, maxAmount);

        bundle.push(Call(_getWithdrawData(amount), false));

        vars.expectedBundlerBorrowableBalance += amount;

        uint256 expectedDecreasedSupplyShares = amount.toSharesUp(vars.expectedTotalSupply, vars.expectedSupplyShares);
        vars.expectedTotalSupply -= amount;
        vars.expectedSupplyShares -= expectedDecreasedSupplyShares;
    }

    function _addBorrowData(BundleTransactionsVars memory vars, uint256 shares) internal {
        uint256 availableLiquidity = vars.expectedTotalSupply - vars.expectedTotalBorrow;
        if (availableLiquidity == 0 || vars.expectedCollateral == 0) return;

        uint256 totalBorrowPower = vars.expectedCollateral.wMulDown(marketParams.lltv);

        uint256 borrowed = vars.expectedBorrowShares.toAssetsUp(vars.expectedTotalBorrow, vars.expectedBorrowShares);

        uint256 currentBorrowPower = totalBorrowPower - borrowed;
        if (currentBorrowPower == 0) return;

        uint256 maxShares = UtilsLib.min(currentBorrowPower, availableLiquidity).toSharesDown(
            vars.expectedTotalBorrow, vars.expectedBorrowShares
        );
        if (maxShares < MIN_AMOUNT) return;
        shares = bound(shares % maxShares, MIN_AMOUNT, maxShares);

        bundle.push(Call(_getBorrowData(shares), false));

        uint256 expectedBorrowedAmount = shares.toAssetsDown(vars.expectedTotalBorrow, vars.expectedBorrowShares);
        vars.expectedBundlerBorrowableBalance += expectedBorrowedAmount;

        vars.expectedTotalBorrow += expectedBorrowedAmount;
        vars.expectedBorrowShares += shares;
    }

    function _addRepayData(BundleTransactionsVars memory vars, uint256 amount, address user) internal {
        if (vars.expectedBorrowShares == 0) return;

        uint256 borrowBalance =
            vars.expectedBorrowShares.toAssetsDown(vars.expectedTotalBorrow, vars.expectedBorrowShares);

        amount = bound(amount % borrowBalance, 1, borrowBalance);

        _transferMissingBorrowable(vars, amount);

        bundle.push(Call(_getRepayData(amount, user), false));

        vars.expectedBundlerBorrowableBalance -= amount;

        uint256 expectedDecreasedBorrowShares = amount.toSharesDown(vars.expectedTotalBorrow, vars.expectedBorrowShares);
        vars.expectedTotalBorrow -= amount;
        vars.expectedBorrowShares -= expectedDecreasedBorrowShares;
    }

    function _addWithdrawCollateralData(BundleTransactionsVars memory vars, uint256 amount) internal {
        if (vars.expectedCollateral == 0) return;

        uint256 borrowPower = vars.expectedCollateral.wMulDown(marketParams.lltv);
        uint256 borrowed = vars.expectedBorrowShares.toAssetsUp(vars.expectedTotalBorrow, vars.expectedBorrowShares);

        uint256 withdrawableCollateral = (borrowPower - borrowed).wDivDown(marketParams.lltv);
        if (withdrawableCollateral == 0) return;

        amount = bound(amount % withdrawableCollateral, 1, withdrawableCollateral);

        bundle.push(Call(_getWithdrawCollateralData(amount), false));

        vars.expectedBundlerCollateralBalance += amount;

        vars.expectedCollateral -= amount;
    }

    function _transferMissingBorrowable(BundleTransactionsVars memory vars, uint256 amount) internal {
        if (amount > vars.expectedBundlerBorrowableBalance) {
            uint256 missingAmount = amount - vars.expectedBundlerBorrowableBalance;
            bundle.push(Call(_getTransferFrom2Data(address(borrowableToken), missingAmount), false));
            vars.initialUserBorrowableBalance += missingAmount;
            vars.expectedBundlerBorrowableBalance += missingAmount;
        }
    }

    function _transferMissingCollateral(BundleTransactionsVars memory vars, uint256 amount) internal {
        if (amount > vars.expectedBundlerCollateralBalance) {
            uint256 missingAmount = amount - vars.expectedBundlerCollateralBalance;
            bundle.push(Call(_getTransferFrom2Data(address(collateralToken), missingAmount), false));
            vars.initialUserCollateralBalance += missingAmount;
            vars.expectedBundlerCollateralBalance += missingAmount;
        }
    }

    function testFlashLoan(uint256 amount) public {
        amount = bound(amount, MIN_AMOUNT, MAX_AMOUNT);

        borrowableToken.setBalance(address(this), amount);
        morpho.supply(marketParams, amount, 0, SUPPLIER, hex"");

        callbackBundle.push(Call(abi.encodeCall(BaseBundler.transfer, (address(borrowableToken), USER, amount)), false));
        callbackBundle.push(
            Call(abi.encodeCall(Permit2Bundler.transferFrom2, (address(borrowableToken), amount)), false)
        );

        bundle.push(
            Call(
                abi.encodeCall(
                    MorphoBundler.morphoFlashLoan, (address(borrowableToken), amount, abi.encode(callbackBundle))
                ),
                false
            )
        );

        assertEq(borrowableToken.balanceOf(USER), 0, "User's borrowable token balance");
        assertEq(borrowableToken.balanceOf(address(bundler)), 0, "Bundler's borrowable token balance");
        assertEq(borrowableToken.balanceOf(address(morpho)), amount, "Morpho's borrowable token balance");
    }
}
