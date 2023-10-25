// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {CompoundV3Authorization} from "../../helpers/SigUtils.sol";

import "../../../../src/migration/CompoundV3MigrationBundler.sol";

import "./helpers/EthereumMigrationTest.sol";

contract CompoundV3MigrationBundlerEthereumTest is EthereumMigrationTest {
    using SafeTransferLib for ERC20;
    using MarketParamsLib for MarketParams;
    using MorphoLib for IMorpho;
    using MorphoBalancesLib for IMorpho;

    uint256 collateralSupplied = 10 ether;
    uint256 borrowed = 1 ether;

    function setUp() public override {
        super.setUp();

        _initMarket(CB_ETH, WETH);

        bundler = new CompoundV3MigrationBundler(address(morpho));
    }

    function testCompoundV3RepayZeroAmount() public {
        bundle.push(_compoundV3Repay(C_WETH_V3, marketParams.loanToken, 0));

        vm.expectRevert(bytes(ErrorsLib.ZERO_AMOUNT));
        bundler.multicall(bundle);
    }

    function testAaveV3OtimizerAuthorizationWithSigRevert() public {
        uint8 v;
        bytes32 r;
        bytes32 s;

        bundle.push(
            abi.encodeCall(
                CompoundV3MigrationBundler.compoundV3AllowBySig,
                (C_WETH_V3, true, 0, SIGNATURE_DEADLINE, v, r, s, false)
            )
        );

        vm.expectRevert();
        bundler.multicall(bundle);
    }

    function testMigrateBorrowerWithCompoundAllowance(uint256 privateKey) public {
        address user;
        (privateKey, user) = _boundPrivateKey(privateKey);

        _provideLiquidity(borrowed);

        deal(marketParams.collateralToken, user, collateralSupplied);

        vm.startPrank(user);
        ERC20(marketParams.collateralToken).safeApprove(C_WETH_V3, collateralSupplied);
        ICompoundV3(C_WETH_V3).supply(marketParams.collateralToken, collateralSupplied);
        ICompoundV3(C_WETH_V3).withdraw(marketParams.loanToken, borrowed);
        vm.stopPrank();

        callbackBundle.push(_morphoSetAuthorizationWithSig(privateKey, true, 0, false));
        callbackBundle.push(_morphoBorrow(marketParams, borrowed, 0, address(bundler)));
        callbackBundle.push(_morphoSetAuthorizationWithSig(privateKey, false, 1, false));
        callbackBundle.push(_compoundV3Repay(C_WETH_V3, marketParams.loanToken, borrowed));
        callbackBundle.push(_compoundV3Allow(privateKey, C_WETH_V3, address(bundler), true, 0, false));
        callbackBundle.push(_compoundV3WithdrawFrom(C_WETH_V3, marketParams.collateralToken, collateralSupplied));
        callbackBundle.push(_compoundV3Allow(privateKey, C_WETH_V3, address(bundler), false, 1, false));

        bundle.push(_morphoSupplyCollateral(marketParams, collateralSupplied, user));

        vm.prank(user);
        bundler.multicall(bundle);

        _assertBorrowerPosition(collateralSupplied, borrowed, user, address(bundler));
    }

    function testMigrateSupplierWithCompoundAllowance(uint256 privateKey, uint256 supplied) public {
        address user;
        (privateKey, user) = _boundPrivateKey(privateKey);
        supplied = bound(supplied, 101, 100 ether);

        deal(marketParams.loanToken, user, supplied);

        vm.startPrank(user);
        ERC20(marketParams.loanToken).safeApprove(C_WETH_V3, supplied);
        ICompoundV3(C_WETH_V3).supply(marketParams.loanToken, supplied);
        vm.stopPrank();

        // Margin necessary due to CompoundV3 roundings.
        supplied -= 100;

        bundle.push(_compoundV3Allow(privateKey, C_WETH_V3, address(bundler), true, 0, false));
        bundle.push(_compoundV3WithdrawFrom(C_WETH_V3, marketParams.loanToken, supplied));
        bundle.push(_compoundV3Allow(privateKey, C_WETH_V3, address(bundler), false, 1, false));
        bundle.push(_morphoSupply(marketParams, supplied, 0, user));

        vm.prank(user);
        bundler.multicall(bundle);

        _assertSupplierPosition(supplied, user, address(bundler));
    }

    function testMigrateSupplierWithPermit2(uint256 privateKey, uint256 supplied) public {
        address user;
        (privateKey, user) = _boundPrivateKey(privateKey);
        supplied = bound(supplied, 101, 100 ether);

        deal(marketParams.loanToken, user, supplied);

        vm.startPrank(user);
        ERC20(marketParams.loanToken).safeApprove(C_WETH_V3, supplied);
        ICompoundV3(C_WETH_V3).supply(marketParams.loanToken, supplied);
        vm.stopPrank();

        // Margin necessary due to CompoundV3 roundings.
        supplied -= 100;

        uint256 cTokenBalance = ICompoundV3(C_WETH_V3).balanceOf(user);

        bundle.push(_permit2TransferFrom(privateKey, C_WETH_V3, cTokenBalance, 0));
        bundle.push(_compoundV3Withdraw(C_WETH_V3, marketParams.loanToken, supplied));
        bundle.push(_morphoSupply(marketParams, supplied, 0, user));

        vm.startPrank(user);
        ERC20(C_WETH_V3).safeApprove(address(Permit2Lib.PERMIT2), type(uint256).max);
        bundler.multicall(bundle);
        vm.stopPrank();

        _assertSupplierPosition(supplied, user, address(bundler));
    }

    function testMigrateSupplierToVaultWithCompoundAllowance(uint256 privateKey, uint256 supplied) public {
        address user;
        (privateKey, user) = _boundPrivateKey(privateKey);
        supplied = bound(supplied, 101, 100 ether);

        deal(marketParams.loanToken, user, supplied);

        vm.startPrank(user);
        ERC20(marketParams.loanToken).safeApprove(C_WETH_V3, supplied);
        ICompoundV3(C_WETH_V3).supply(marketParams.loanToken, supplied);
        vm.stopPrank();

        // Margin necessary due to CompoundV3 roundings.
        supplied -= 100;

        bundle.push(_compoundV3Allow(privateKey, C_WETH_V3, address(bundler), true, 0, false));
        bundle.push(_compoundV3WithdrawFrom(C_WETH_V3, marketParams.loanToken, supplied));
        bundle.push(_compoundV3Allow(privateKey, C_WETH_V3, address(bundler), false, 1, false));
        bundle.push(_erc4626Deposit(address(suppliersVault), supplied, user));

        vm.prank(user);
        bundler.multicall(bundle);

        _assertVaultSupplierPosition(supplied, user, address(bundler));
    }

    function testMigrateSupplierToVaultWithPermit2(uint256 privateKey, uint256 supplied) public {
        address user;
        (privateKey, user) = _boundPrivateKey(privateKey);
        supplied = bound(supplied, 101, 100 ether);

        deal(marketParams.loanToken, user, supplied);

        vm.startPrank(user);
        ERC20(marketParams.loanToken).safeApprove(C_WETH_V3, supplied);
        ICompoundV3(C_WETH_V3).supply(marketParams.loanToken, supplied);
        vm.stopPrank();

        // Margin necessary due to CompoundV3 roundings.
        supplied -= 100;

        uint256 cTokenBalance = ICompoundV3(C_WETH_V3).balanceOf(user);

        bundle.push(_permit2TransferFrom(privateKey, C_WETH_V3, cTokenBalance, 0));
        bundle.push(_compoundV3Withdraw(C_WETH_V3, marketParams.loanToken, supplied));
        bundle.push(_erc4626Deposit(address(suppliersVault), supplied, user));

        vm.startPrank(user);
        ERC20(C_WETH_V3).safeApprove(address(Permit2Lib.PERMIT2), type(uint256).max);
        bundler.multicall(bundle);
        vm.stopPrank();

        _assertVaultSupplierPosition(supplied, user, address(bundler));
    }

    /* ACTIONS */

    function _compoundV3Allow(
        uint256 privateKey,
        address instance,
        address manager,
        bool isAllowed,
        uint256 nonce,
        bool skipRevert
    ) internal view returns (bytes memory) {
        bytes32 digest = SigUtils.toTypedDataHash(
            instance, CompoundV3Authorization(vm.addr(privateKey), manager, isAllowed, nonce, SIGNATURE_DEADLINE)
        );

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, digest);

        return abi.encodeCall(
            CompoundV3MigrationBundler.compoundV3AllowBySig,
            (instance, isAllowed, nonce, SIGNATURE_DEADLINE, v, r, s, skipRevert)
        );
    }

    function _compoundV3Repay(address instance, address asset, uint256 amount) internal pure returns (bytes memory) {
        return abi.encodeCall(CompoundV3MigrationBundler.compoundV3Repay, (instance, asset, amount));
    }

    function _compoundV3Withdraw(address instance, address asset, uint256 amount)
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeCall(CompoundV3MigrationBundler.compoundV3Withdraw, (instance, asset, amount));
    }

    function _compoundV3WithdrawFrom(address instance, address asset, uint256 amount)
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeCall(CompoundV3MigrationBundler.compoundV3WithdrawFrom, (instance, asset, amount));
    }
}
